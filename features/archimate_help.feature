 Feature: archimate command line help

  The archimate tool has built in help for the tool in general and each of the sub-commands.

  Scenario: General Help: running archimate without arguments
    When I successfully run `bin/archimate`
    Then the output should contain:
      """
      Commands:
      """
    And the output should contain:
      """
      archimate clean ARCHIFILE
      """
    And the output should contain:
      """
      archimate convert ARCHIFILE
      """
    And the output should contain:
      """
      archimate dedupe ARCHIFILE
      """
    And the output should contain:
      """
      archimate dupes ARCHIFILE
      """
    And the output should contain:
      """
      archimate help [COMMAND]
      """
    And the output should contain:
      """
      archimate lint ARCHIFILE
      """
    And the output should contain:
      """
      archimate map ARCHIFILE
      """
    And the output should contain:
      """
      archimate merge ARCHIFILE1 ARCHIFILE2
      """
    And the output should contain:
      """
      archimate stats ARCHIFILE
      """
    And the output should contain:
      """
      archimate svg -o OUTPUTDIR ARCHIFILE o, --output=OUTPUT
      """

  Scenario: Help on a particular command
    When I successfully run `bin/archimate help clean`
    Then the output should contain:
      """
      Usage:
      """
    And the output should contain:
      """
      archimate clean ARCHIFILE
      """

