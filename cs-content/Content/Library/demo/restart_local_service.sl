########################################################################################################################
#!!
#! @description: Restarts local Windows service
#!
#! @input service_name: Service to be restarted
#!
#! @output return_result:
#! @output return_code:
#! @output error_message:
#!
#! @result SUCCESS: Flow completed successfully.
#! @result FAILURE: Failure occurred during execution.
#!!#
########################################################################################################################

namespace: io.cloudslang.demo

flow:
    name: restart_local_service

    inputs:
      - service_name: "Tomcat6"

    workflow:
      - stop_service:
          do:
            io.cloudslang.demo.sub_flows.run_command:
              - command: ${'net stop '+service_name}
          publish:
              - return_result
              - return_code
              - error_message
          navigate:
            - SUCCESS: start_service
            - FAILURE: start_service    #try to start the service even when stopping it failed (might have been stopped already)
      - start_service:
          do:
            io.cloudslang.demo.sub_flows.run_command:
              - command: ${'net start '+service_name}
          publish:
              - return_result
              - return_code
              - error_message
    outputs:
      - return_result
      - return_code
      - error_message

    results:
      - SUCCESS
      - FAILURE