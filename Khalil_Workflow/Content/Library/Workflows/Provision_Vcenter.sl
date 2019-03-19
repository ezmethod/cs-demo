namespace: Workflows
flow:
  name: Provision_Vcenter
  workflow:
    - provision_windows_vm:
        do:
          io.cloudslang.vmware.vcenter.provision_windows_vm: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      provision_windows_vm:
        x: 170
        y: 128
        navigate:
          a98afa59-f4c4-c7c0-5cca-e834df776006:
            targetId: 393c58a8-a2b2-16f7-dc4b-272ef40c2616
            port: SUCCESS
          823d4052-9527-fe68-6f8a-48cdaf6617a7:
            targetId: abccf17f-7ba7-dbd7-ecb8-a66c3e2e8497
            port: FAILURE
    results:
      SUCCESS:
        393c58a8-a2b2-16f7-dc4b-272ef40c2616:
          x: 395
          y: 116
      FAILURE:
        abccf17f-7ba7-dbd7-ecb8-a66c3e2e8497:
          x: 338
          y: 309
