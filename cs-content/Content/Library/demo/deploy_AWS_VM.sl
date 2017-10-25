########################################################################################################################
#!!
#! @description: Deploys, stops and undeploy a machine in AWS EC2
#!
#! @result SUCCESS: Flow completed successfully.
#! @result FAILURE: Failure occurred during execution.
#!!#
########################################################################################################################

namespace: io.cloudslang.demo
imports:
  ec2: io.cloudslang.amazon.aws.ec2

flow:
    name: deploy_AWS_VM

    inputs:
      - identity
      - credential
      - image_id: 'ami-8c1be5f6'  # amazon linux us-east-1c
#      - image_id: 'ami-c5062ba0'  # amazon linux us-east-2b
      - instance_type: 't2.micro'

    workflow:
      - deploy_instance:
          do:
            ec2.deploy_instance:
              - identity
              - credential
              - image_id
              - instance_type
              - availability_zone: 'us-east-1c'  # N.Virginia
#              - availability_zone: 'us-east-2b'   # Ohio
#              - endpoint: 'https://ec2.us-east-2.amazonaws.com'
          publish:
            - instance_id
            - ip_address
            - return_result
            - return_code
            - exception
          navigate:
            - SUCCESS: sleep
            - FAILURE: FAILURE
      - sleep:
          do:
            io.cloudslang.base.utils.sleep:
              - seconds: '60'
          navigate:
            - SUCCESS: stop_instance
            - FAILURE: FAILURE
      - stop_instance:
          do:
            ec2.stop_instance:
              - identity
              - credential
              - instance_id
              - force_stop: 'false'
          publish:
            - return_code
            - exception
          navigate:
            - SUCCESS: sleep2
            - FAILURE: sleep2   # it's failing even though the instance is stopped
      - sleep2:
          do:
            io.cloudslang.base.utils.sleep:
              - seconds: '60'
          navigate:
            - SUCCESS: undeploy_instance
            - FAILURE: FAILURE
      - undeploy_instance:
          do:
            ec2.undeploy_instance:
              - identity
              - credential
              - instance_id
          publish:
            - return_result
            - return_code
            - exception
          navigate:
            - SUCCESS: SUCCESS
            - FAILURE: FAILURE

    outputs:
        - instance_id
        - ip_address
        - return_result
        - return_code
        - exception

    results:
      - SUCCESS
      - FAILURE