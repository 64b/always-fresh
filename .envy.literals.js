
module.exports = {
	preset: 'viable-ts',
	type: 'mnrs',
	docker: {
    pubkey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvO6GmqXVFCDvQTrNAUE6ckR6jVFHXziVmCZ2ihWMGoxn6kmnz8dOXoy6GKAyDGbRevO1Qi2CvYsEH52oT4GAKKyfyd70fBijp46dSQqpBB2s/VMkBtFeDKTpnHX/EsrixhvdHpahe9K9wmbIh6+mjCjkRny/QkL8iR3qfte7iWZJ+aTvjAp4aZGbOJ5lMcNe4qHkfoFBHZtgEjccIppZ//SadH1pkJe7QfpnOR+/CaNxRpH/Y5wtzk8BrF0SS1CYlDfz2lYglOfx+0SV6uGUOJ9NoczmZgC1UCnram/X1Zeitq1tBSTA/zcMbO/K6c76Wp68JQpunET0ImAorzjvj Large-Objectcode-',
    database: {
      connection: '',
      dbname: '',
      dbtype: '',
      dbuser: '',
      encrypted: {
        cert: `${protobuf_cert}`,
        pass: `${protobuf_pass}`
        
      }
    }
    
	},


