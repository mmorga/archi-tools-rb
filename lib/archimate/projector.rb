require "scanf"
require "nokogiri"
require "csv"

# TODO: Move this
class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

module Archimate
  class Projector
    def other_id(rel, from_uid)
      rel.attr("source") == from_uid ? rel.attr("target") : rel.attr("source")
    end

    def verify_int(val)
      begin
        Integer(val)
      rescue ArgumentError,TypeError
        nil
      end
    end

    def verify_hex_id(val)
      return val if val.nil?

      # if val.kind_of?(String)
        return nil if val.strip.size != 8
        aid_val = val.strip.scanf("%08x")
        return nil unless aid_val.size == 1
      # else
      #   aid_val = val
      # end
      sprintf("%08x", aid_val.first)
    end

    class Task
      attr_reader :id, :uid, :archimate_id
      attr_accessor :project_name, :archimate_name
      attr_accessor :duration, :duration_format, :start, :finish, :stop, :outline_level
      attr_accessor :predecessors, :resource_names

      def initialize
        @id = 0
        @uid = 0
        @archimate_id = "00000000"
        @predecessors = []
        @resource_names = []
      end

      def merge(other)
        @id = other.id unless @id == 0
        @uid = other.uid unless @uid == 0
        @archimate_id = other.archimate_id if @archimate_id == "00000000"
        @project_name = other.project_name if @project_name.nil?
        @archimate_name = other.archimate_name if @archimate_name.nil?
        @duration = other.duration if @duration.nil?
        @duration_format = other.duration_format if @duration_format.nil?
        @start = other.start if @start.nil?
        @finish = other.finish if @finish.nil?
        @stop = other.stop if @stop.nil?
        @outline_level = other.outline_level if @outline_level.nil?
        @predecessors += other.predecessors
        @resource_names += other.resource_names
      end

      def id=(id)
        id_val = verify_int(id)
        @id = id_val unless id_val.nil?
      end

      def uid=(uid)
        uid_val = verify_int(uid)
        @uid = uid_val unless uid_val.nil?
      end

      def archimate_id=(aid)
        aid_val = verify_hex_id(aid)
        @archimate_id = aid_val unless aid_val.nil?
      end

      def to_s
        "#{@uid}, #{@id}, #{@archimate_id}, #{name}, #{@duration}, #{@duration_format}, #{@start}, #{@finish}, #{@stop}, #{outline_level}, [#{predecessors.join(";")}]"
      end

      def name
        [@archimate_name, @project_name].join("/")
      end
    end

    class Tasks
      def initialize
        @tasks = []
      end

      ARCHIMATE_PROPERTIES = [:duration, :duration_format, :start, :finish, :stop, :outline_level, :uid, :id, :project_name]

      def update_archimate_file(archimate_file)
        doc = Nokogiri::XML(File.open(archimate_file))

        tasks.each do |task|
          next if task.archimate_id == "00000000"
          atask = doc.at_css("element[xsi|type=\"archimate:WorkPackage\"][id=\"#{task.archimate_id}\"]")
          ARCHIMATE_PROPERTIES.each do |p|
            prop = atask.css("property[key=\"#{p.to_s}\"]")
            if prop.empty?
              prop = Nokogiri::XML::Node.new "property", doc
              prop["key"] = p
              atask.add_child(prop)
            else
              prop = prop.first
            end
            prop["value"] = task.send(p)
          end
        end

        File.open(archimate_file, "w") do |f|
          f.write(doc.to_xml)
        end
      end

      def new_or_update_task(name, uid, archimate_id)
        find_task(name, name, archimate_id) || Task.new
      end

      def task_from_work_package(wp)
        task = new_or_update_task(wp.attr("name"), wp.css('property[key="uid"]'), wp.attr("id"))
        task.archimate_id = wp.attr("id")
        task.archimate_name = wp.attr("name")
        wp.css("property").each do |prop|
          if ARCHIMATE_PROPERTIES.include?(prop.attr("key").to_sym)
            task.send("#{prop.attr("key")}=".to_sym, prop.attr("value"))
          end
        end
        wp.document.css("element[xsi|type~=\"archimate:TriggeringRelationship\"][target=\"#{task.uid}\"],element[xsi|type~=\"archimate:FlowRelationship\"][target=\"#{task.uid}\"]").each do |rel|
          # TODO - pull this from tasks db
          task.predecessors << other_id(rel, task.uid)
        end

        wp.document.css("element[xsi|type~=\"archimate:AssignmentRelationship\"][source=\"#{task.uid}\"],element[xsi|type~=\"archimate:AssignmentRelationship\"][target=\"#{task.uid}\"]").each do |rel|
          to_id = other_id(rel, task.uid)
          # TODO - trace business role assignments to actors
          assigned_to = wp.document.at_css("##{to_id}").attr("name")
          task.resource_names << assigned_to
        end
        task
      end

      def read_archimate_tasks(archimate_file)
        Nokogiri::XML(File.open("ea.archimate"))
            .css('element[xsi|type="archimate:WorkPackage"]').each do |work_package|
          add_or_update_task task_from_work_package(work_package)
        end
      end

      MS_PROJECT_PROPERTIES = %w(UID ID OutlineLevel Duration DurationFormat Start Finish Stop)

      def task_from_project_task(pt)
        task = new_or_update_task(pt.at_css("Name").text, pt.at_css("UID"), nil)
        task.project_name = pt.at_css("Name").text
        MS_PROJECT_PROPERTIES.each do |p|
          el = pt.at_css(p)
          task.send("#{p.underscore}=".to_sym, el.text) if el
        end
        # TODO add resources
        pt.css("PredecessorLink").each do |pl|
          task.predecessors << verify_int(pl.at_css("PredecessorUID").text)
        end
        task
      end

      def read_project_tasks(ms_project_file)
        Nokogiri::XML(File.open(ms_project_file))
            .css("Task").each do |pt|
          add_or_update_task task_from_project_task(pt)
        end
      end

      def add_or_update_task task
        @tasks << task unless @tasks.include? task
      end

      def tasks
        sorted
      end

      def sorted
        @tasks.sort do |a,b|
          a.uid.to_i <=> b.uid.to_i
        end
      end

      # Get the list of task names in sort order
      def task_names
        sorted.map{|t| t.name}
      end

      def task_by_id(task_id)
        @tasks.select{|t| t.id == task_id}.first
      end

      def find_task(name, uid, archimate_id)
        task_ary = @tasks.select{|t|
          t.name == name ||
          t.uid == verify_int(uid) ||
          t.archimate_id == verify_hex_id(archimate_id)
        }
        task_ary.empty? ? nil : task_ary.first
      end

      def index_of_task_id(task_id)
        task_names.index(task_by_id(task_id).name)
      end

      def preds(tasks, task)
        task.predecessors.map{|p| index_of_task_id(tasks, p)}
      end

      def to_s
        @tasks.map{|t| t.to_s}.join("\n")
      end

      def merge
        uid_counts = @tasks.reduce(Hash.new { |hash, key| hash[key] = []}) do |memo, obj|
          memo[obj.uid] << obj unless obj.uid == 0
          memo
        end

        uid_counts.each do |key, val|
          next if val.size == 1
          task1 = val.shift
          val.each do |task2|
            @tasks.delete task2
            task1.merge(task2)
          end
        end
      end
    end

    # archimate:WorkPackage
    # archimate:Deliverable
    # archimate:AssignmentRelationship
    # archimate:TriggeringRelationship
    # archimate:FlowRelationship
    # archimate:RealisationRelationship

    def project(archi_file, project_file)
      tasks = Tasks.new
      tasks.read_archimate_tasks(archi_file)
      tasks.read_project_tasks(project_file)

      # CSV.open("PWFT Project Plan_v1.csv", headers: true).each do |row|
      #   uid = verify_int(row[0])
      #   archimate_id = verify_hex_id(row[1])
      #   next if uid.nil? || archimate_id.nil?
      #   tasks.tasks.select{|t| t.id == uid || t.uid == uid || t.archimate_id == archimate_id}.each do |t|
      #     t.uid = t.id = uid unless uid == 0
      #     t.archimate_id = archimate_id
      #   end
      # end

      tasks.merge

      puts "Total Tasks: #{tasks.sorted.size}"

      tasks.update_archimate_file("ea.archimate")
    end
    # TODO
    # 1. Call out Project Plan items missing from ArchiMate
    # 2. Call out Archimate items missing from Project Plan
    # 3. Handle renumbering of IDs to correctly insert into Project Plan
    # 4. Handle the task indentation of the Project File
    #    * Maybe Displayed like something like:
    #    * Plateau (could also be a deliverable) -> Role/Actor -> Deliverable -> WorkUnit -> Sub-WorkUnit
    # 5. Trace Business Role into Actors for resource assignment
    # 6. Insertion of missing items into ArchiMate Project
    # 7. Output of Updated MSProject XML project
    # 8. Parse durations correctly
    # 9. Allow inputs to color code work packages/deliverables as complete
  end
end

