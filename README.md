# Jenkins Complete CI/CD Pipeline Environment Setup 

## CICD Applications setup
1) ###### GitHub setup
    Fork GitHub Repository by using the existing repo "jjtech-ci-cd-pipeline-project-k8s" (https://github.com/anselmenumbisia/jjtech-ci-cd-pipeline-project-k8s.git)     
    - Go to GitHub (github.com)
    - Login to your GitHub Account
    - **Fork repository "jjtech-ci-cd-pipeline-project-k8s" (https://github.com/anselmenumbisia/jjtech-ci-cd-pipeline-project-k8s.git)**
    - Clone your newly created repo to your local


2) ###### Jenkins/Maven/Ansible/terraform
    - Create an **Amazon Linux 2 VM** instance and call it "Jenkins" !!! Do not use a linux2023 AMI
    - Instance type: t2.large
    - Security Group (Open): 8080, 9100 and 22 to 0.0.0.0/0
    - Key pair: Select or create a new keypair
    - **Attach Jenkins server with IAM role having "AdministratorAccess"**
    - User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/jenkins-maven-ansible-setup.sh
    - Launch Instance
    - After launching this Jenkins server, attach a tag as **Key=Application, value=jenkins**

3) ###### SonarQube
    - Create an Create an **Ubuntu 20.04** VM instance and call it "SonarQube"
    - Instance type: t2.medium
    - Security Group (Open): 9000, 9100 and 22 to 0.0.0.0/0
    - Key pair: Select or create a new keypair
    - User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/sonarqube-setup.sh
    - Launch Instance

4) ###### Nexus
    - Create an **Amazon Linux 2** VM instance and call it "Nexus" !!! Do not use a linux2023 AMI
    - Instance type: t2.medium
    - Security Group (Open): 8081, 9100 and 22 to 0.0.0.0/0
    - Key pair: Select or create a new keypair
    - User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/nexus-setup.sh
    - Launch Instance

5) ######  S3 and Dynamodb
- create s3 bucket and dynamodb table for terraform backend. Partition key for dynamo db must be "LockID"
- Replace values for s3 and dynamodb in provider.tf file ln 4-12

### Jenkins setup
1) #### Access Jenkins
    Copy your Jenkins Public IP Address and paste on the browser = ExternalIP:8080
    - Login to your Jenkins instance using your Shell (GitBash or your Mac Terminal)
    - Copy the Path from the Jenkins UI to get the Administrator Password
        - Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
        - Copy the password and login to Jenkins
    - Plugins: Choose Install Suggested Plugings 
    - Provide 
        - Username: **admin**
        - Password: **admin**
        - Name and Email can also be admin. You can use `admin` all, as its a poc.
    - Continue and Start using Jenkins

2)  #### Plugin installations:
    - Click on "Manage Jenkins"
    - Click on "Plugin Manager"
    - Click "Available"
    - Search and Install the following Plugins "Install Without Restart"
        - **SonarQube Scanner**
        - **maven Integration**
        - **Terraform**
        - **ssh pipeline**
        
    - Once all plugins are installed, select **Restart Jenkins when installation is complete and no jobs are running**


3)  #### Pipeline creation
    - Click on **New Item**
    - Enter an item name: **app-cicd-pipeline** & select the category as **Pipeline**
    - Now scroll-down and in the Pipeline section --> Definition --> Select Pipeline script from SCM
    - SCM: **Git**
    - Repositories
        - Repository URL: FILL YOUR OWN REPO URL (that we created by importing in the first step)
        - Branch Specifier (blank for 'any'): */main
        - Script Path: spring-boot-app/Jenkinsfile
    - Save

4)  #### Global tools configuration:
    - Click on Manage Jenkins --> Global Tool Configuration

        **JDK** --> Add JDK --> Make sure **Install automatically** is enabled --> 
        
        **Note:** By default the **Install Oracle Java SE Development Kit from the website** make sure to close that option by clicking on the image as shown below.

        ![JDKSetup!](https://github.com/cvamsikrishna11/devops-fully-automated/blob/main/jdk_setup.png)

        * Click on Add installer
        * Select Extract *.zip/*.tar.gz --> Fill the below values
        * Name: **localJdk**
        * Download URL for binary archive: **https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz**
        * Subdirectory of extracted archive: **jdk-11.0.1**

    - **Maven** --> Add Maven --> Make sure **Install automatically** is enabled --> Install from Apache --> Fill the below values
        * Name: **localMaven**
        * Version: Keep the default version as it is 

    - **Terraform** --> Add Terraform --> Make sure **Install automatically** is enabled --> Install from Bintray.com --> Fill the below values:
     * Name: terraform
     * Version: Leave it to default and change to linux (amd64)
     * click on save


5)  #### Credentials setup(SonarQube, Nexus):
    - Click on Manage Jenkins --> Manage Credentials --> Global credentials (unrestricted) --> Add Credentials

        1)  #### SonarQube secret token (sonarqube-token)
            - Kind: Secret text :
                    Generating SonarQube secret token
                    - Login to your SonarQube server (http://sonarserver-public-ip:9000, with the credentials username: **admin** & password: **admin**)
                    - Click on profile --> My Account --> Security --> Tokens
                    - Generate Tokens: Fill **jenkins-token**
                    - Click on **Generate**
                    - Copy the token
            - Secret: Fill the secret token value that we have created on the SonarQube server
            - ID: sonarqube-token
            - Description: sonarqube-token
            - Click on Create

        2)  #### Nexus username & password (nexus-credentials)
            - Kind: Username with password                  
            - Username: admin
            - Enable Treat username as secret
            - Password: admin
            - ID: nexus-credentials
            - Description: nexus-credentials
            - Click on Create  

6)  #### Configure system:    

        1)  - Click on Manage Jenkins --> System
            - Go to section SonarQube servers --> **Add SonarQube **
            - Name: **SonarQube**
            - Server URL: http://REPLACE-WITH-SONARQUBE-SERVER-PRIVATE-IP:9000          (replace SonarQube privat IP here)
            - Server authentication token --> replace with sonarqube token credendtials configured in previous step
            - Click on Save   

### SonarQube setup

Copy your SonarQube Public IP Address and paste on the browser = ExternalIP:9000

1)  #### Jenkins webhook in SonarQube:
    - Login into SonarQube
    - Go to Administration --> Configuration --> Webhooks --> Click on Create
    - Name: Jenkins-Webhook
    - URL: http://REPLACE-WITH-JENKINS-PRIVATE-IP:8080/sonarqube-webhook/ (replace Jenkins private IP here)
    - Click on Create


### Nexus setup

Copy your Nexus Public IP Address and paste on the browser = http:://NexusServerExternalIP:8081

1)  #### Setting up password:
    - SSH into Nexus server
    - Execute `sudo cat /opt/nexus/sonatype-work/nexus3/admin.password`
    - Copy the default password
    - Now login into Nexus console with the username: admin & password (copied from the SSH above)
    - Once signed in fill the below details in the setup wizard
    - New password: admin
    - Confirm password: admin
    - Configure anonymus access: Select Disable anonymus access
    - Click on Finish

2)  #### Creating a new maven repository for project:
    - Once login to the Nexus server, click on Settings icon --> Repository --> Repositories
    - Click on Create repository
    - Select maven2(group)
    - Name: maven_project
    - Scroll-down to Group section & select all the available repositories (maven-snapshots, maven-public, maven-releases, maven-central) as members
    Hint: You can select one repo at a time and click on > symbol to add the repo as group member.
    - Once all the repositories are added to the group, click on Create repository


### GitHub webhook

1) #### Add jenkins webhook to github
    - Access your repo **jjtech-ci-cd-pipeline-project-k8s** on github
    - Goto Settings --> Webhooks --> Click on Add webhook 
    - Payload URL: **http://REPLACE-JENKINS-SERVER-PUBLIC-IP:8080/github-webhook/**             (Note: The IP should be public as GitHub is outside of the AWS VPC where Jenkins server is hosted)
    - Click on Add webhook

2) #### Configure on the Jenkins side to pull based on the event
    - Access your jenkins server, pipeline **app-cicd-pipeline**
    - Once pipeline is accessed --> Click on Configure --> In the General section --> **Select GitHub project checkbox** and fill your repo URL of the project jjtech-ci-cd-pipeline-project-k8s.
    - Scroll down --> In the Build Triggers section -->  **Select GitHub hook trigger for GITScm polling checkbox**

Once both the above steps are done click on Save.


### Codebase setup

1) #### SonarQube IP change
    - Go back to your local, open your "jjtech-ci-cd-pipeline-project-k8s" project on VSCODE
    - Open "Jenkinsfile" & Replace the SonarQube server private ip on line number 92 (where you have SONAR_URL)
    - Save the changes in both files
    - Finally push changes to repo
        
        `git add .`

        `git commit -m "relevant commit message"`

        `git push`

2) #### Nexus IP's change
    - Go back to your local, open your "jjtech-ci-cd-pipeline-project-k8s" project on VSCODE
    - Open "pom.xml" & Replace the nexus server private ip on line numbers 60 & 64
    - Open nexus-setup/settings.xml & Replace the nexus server private ip on line numbers 21
    - Save the changes in both files
    - Finally push changes to repo

        `git add .`

        `git commit -m "relevant commit message"`

        `git push`

### Docker Registry (ECR)
- Navigate to AWS and search for ECR service
- click to create repository (private) --> Provide repo name (jjtech-demo) --> create repo
- click on **view push commands** to get username and password to push images to repo

### Update aws cli to version 2
- ssh into jenkins server and query version of aws cli by running "aws --version", if version 1, update with below commands
- curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
- unzip awscliv2.zip

- sudo ./aws/install --update

### Modify values in jenkinsfile
- update values in stage "Build and Push Docker Image" with account ID, Repository name, region, 

### Run pipeline
- Navigate back to jenkins and run the pipeline build

### Access Application
- Navigate to ec2 in AWS management console
- Get public of workernode serves for cluster
- modify security group to allow all inbound traffic from everywhere
- copy pulic ip and run on browser e.g http://example_ip:30080