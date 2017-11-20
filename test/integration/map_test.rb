# frozen_string_literal: true

require 'test_helper'

module Archimate
  class MapTest < Minitest::Test
    def test_map_archi_format
      out, err = capture_io do
        Cli::Archi.start ["map", "test/examples/archisurance.archimate"]
      end
      expected = <<~EXPECTED
        Id           | Name                                 | Viewpoint
        -------------+--------------------------------------+------------------------------
        /Views
        4165.png     | Actor Cooperation view               | Total
        3865.png     | Application Behaviour View           | Application Behavior
        4279.png     | Application Cooperation View         | Application Cooperation
        3944.png     | Application Structure View           | Application Structure
        3641.png     | Archimate View                       | Total
        4224.png     | Business Cooperation View            | Total
        3722.png     | Business Function View               | Business Function
        3761.png     | Business Process View                | Business Process
        3999.png     | Business Product View                | Product
        16fe3cf9.png | Goal and Principle View              | Motivation
        4318.png     | Implementation and Installation View | Implementation and Deployment
        3821.png     | Information Structure View           | Information Structure
        4056.png     | Layered View                         | Layered
        3698.png     | Organisation Structure View          | Organization
        3965.png     | Organisation Tree View               | Organization
        4025.png     | Service Realisation View             | Service Realization
        3893.png     | Technical Infrastructure View        | Infrastructure

        17 Diagrams
      EXPECTED
      assert_empty err
      assert_equal expected, Color.uncolor(out).gsub(/ +\n/, "\n")
    end

    def test_map_archimate_model_exchange_format
      out, err = capture_io do
        Cli::Archi.start ["map", "test/examples/ArchiSurance V3.xml"]
      end
      expected = <<~EXPECTED
        Id          | Name                                 | Viewpoint
        ------------+--------------------------------------+----------
        /
        id-5166.png | Actor Cooperation view               | Layered
        id-5285.png | Application Behaviour View           | Layered
        id-5080.png | Application Cooperation View         | Layered
        id-5560.png | Application Structure View           | Layered
        id-5661.png | Archimate View                       | Layered
        id-5120.png | Business Cooperation View            | Layered
        id-5357.png | Business Function View               | Layered
        id-5415.png | Business Process View                | Layered
        id-5221.png | Business Product View                | Layered
        id-5020.png | Goal and Principle View              | Layered
        id-5044.png | Implementation and Installation View | Layered
        id-5312.png | Information Structure View           | Layered
        id-5584.png | Layered View                         | Layered
        id-5387.png | Organisation Structure View          | Layered
        id-5248.png | Organisation Tree View               | Layered
        id-5481.png | Service Realisation View             | Layered
        id-5513.png | Technical Infrastructure View        | Layered

        17 Diagrams
      EXPECTED
      assert_empty err
      assert_equal expected, Color.uncolor(out).gsub(/ +\n/, "\n")
    end
  end
end
