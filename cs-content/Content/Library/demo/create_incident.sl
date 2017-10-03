########################################################################################################################
#!!
#! @description: Creates an incident in Service Now.
#!
#! @input description: Incident description
#!
#! @output number: Number of the created incident
#!
#! @result SUCCESS: Flow completed successfully.
#! @result FAILURE: Failure occurred during execution.
#!!#
########################################################################################################################

namespace: content.io.cloudslang.demo

flow:
    name: create_incident

    inputs:
      - description: "Need to reset password"

    workflow:
      - create_incident:
          do:
            io.cloudslang.itsm.service_now.commons.create_record:
              - host: 'dev30231.service-now.com'
              - table_name: 'incident'
              - username: 'admin'
              - password: 'g0.HP.software'
              - body: ${"{'short_description':'"+description+"','impact':'1','urgency':'1'}"}
          publish:
            - json_output: '${return_result}'
            - system_id
            - error_message
            - return_code
            - status_code
          navigate:
            - SUCCESS: parse_number
            - REST_POST_API_CALL_FAILURE: FAILURE
            - GET_SYSID_FAILURE: FAILURE
      - parse_number:
          do:
            io.cloudslang.base.json.json_path_query:
              - json_object: '${json_output}'
              - json_path: '$.result.number'
          publish:
              - number: '${return_result}'
    outputs:
      - number

    results:
      - SUCCESS
      - FAILURE