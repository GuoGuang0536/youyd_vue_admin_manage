pipeline {
  agent any
  tools {nodejs "nodejs"}
  environment {
        // 阿里云docker仓库凭证 ：这是jenkins管理界面中定义的凭证名称为“aliyun-docker”
        // FRESH_CREDS = credentials('aliyun-docker')
        // BUILD_NUMBER = credentials('aliyun-docker')
        // 仓库docker 地址、镜像名、容器名称
        FRESH_HOST = 'registry.cn-hongkong.aliyuncs.com'
        DOCKER_IMAGE = 'madao_admin_manage'
        DOCKER_CONTAINER = 'madao_manage'
        //测试人员邮箱地址【参数值对外隐藏】
        QA_EMAIL = '1831682775@qq.com'
        BUILD_USER_EMAIL = '1831682775@qq.com'
        REMOTE_SCRIPT = 'sshpass -f /var/jenkins_home/password.txt ssh -t -t -o StrictHostKeyChecking=no root@${INSTANCE_IP}'
        BUILD_USER  = '构建人'
        //接口测试（网络层）的job名，一般由测试人员编写
        ITEST_JOBNAME = 'InterfaceTest_ExpertPatient'
        //git服务全系统只读账号cred_id【参数值对外隐藏】
        CRED_ID='*****-****-****-****-*********'
    }
  stages {
     stage('获取代码') {
       steps {
            sh "pwd"
            sh "rm -rf ./*"
            sh "rm -rf ./node_modules"
            //git credentialsId: '*****-****-****-****-*********', url: 'https://github.com/GuoGuang/ibole_admin_manage.git', branch: 'dev'
            sh "git clone -b dev https://gitee.com/guoguang0536/madao_admin_manage.git"
        }
     }
      stage('Docker打包推送') {
            steps {
                dir(path: "/${WORKSPACE}/madao_admin_manage") {
                    sh "pwd"
                    sh "docker build -t madao_admin_manage:${env.BUILD_ID} ."
                    echo '-->> 3#构建成功-->>'
                    sh "docker login --username=1831682775@qq.com --password ${DOCKER_HUB_PASSWORD} registry.cn-beijing.aliyuncs.com"
                    sh "docker tag madao_admin_manage:${env.BUILD_ID} registry.cn-beijing.aliyuncs.com/madaoo/madao_admin_manage:${env.BUILD_ID}"
                    script {
                        sh "docker push registry.cn-beijing.aliyuncs.com/madaoo/madao_admin_manage:${env.BUILD_ID}"
                        echo "构建并推送到远程服务器成功--->"
                    }
                }
            }
      }
     stage('远程Docker拉取并构建') {
            steps {
                 // jenkins/jenkins镜像是基于Ubuntu系统
                sh "sed -i 's@http://deb.debian.org@https://mirrors.163.com@g' /etc/apt/sources.list"
                sh "apt-get update"
                sh "apt-get install sshpass"

                // jenkinsci/blueocean镜像是基于Alpine Linux系统
                // sh "sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories"
                // sh "apk update"
                // sh "apk add sshpass"
                script {
                    // 停止并删除列表中有 ${DOCKER_CONTAINER} 的容器
                    def container = sh(returnStdout: true, script: "${REMOTE_SCRIPT} docker ps -a | grep $DOCKER_CONTAINER | awk '{print \$1}'").trim()
                    if (container.size() > 0) {
                        sh "${REMOTE_SCRIPT} docker ps -a | grep $DOCKER_CONTAINER | awk  '{print \$1}' | xargs ${REMOTE_SCRIPT} docker stop"
                        sh "${REMOTE_SCRIPT} docker ps -a | grep $DOCKER_CONTAINER | awk '{print \$1}' | xargs ${REMOTE_SCRIPT} docker rm"
                        echo '-->> 1#停止并删除容器 -->>'
                    }
                    // 删除列表中有 ${DOCKER_IMAGE} 的镜像
                    def image = sh(returnStdout: true, script: "${REMOTE_SCRIPT} docker images | grep $DOCKER_IMAGE | awk '{print \$3}'").trim()
                    if (image.size() > 0) {
                        sh "${REMOTE_SCRIPT} docker images | grep $DOCKER_IMAGE | awk '{print \$3}' | xargs ${REMOTE_SCRIPT} docker rmi -f"
                        echo '-->> 2#停止并删除镜像 -->>'
                    }
                }

                sh "${REMOTE_SCRIPT} pwd "
                sh "${REMOTE_SCRIPT} docker -v "
                sh "${REMOTE_SCRIPT} docker login --username=1831682775@qq.com --password ${DOCKER_HUB_PASSWORD} registry.cn-beijing.aliyuncs.com"
                sh "${REMOTE_SCRIPT} docker pull registry.cn-beijing.aliyuncs.com/madaoo/madao_admin_manage:${env.BUILD_ID}"
                sh "${REMOTE_SCRIPT} docker run -p 9527:9527 --name ${DOCKER_CONTAINER} -d registry.cn-beijing.aliyuncs.com/madaoo/madao_admin_manage:${env.BUILD_ID}"
                echo '-->> #远程主机构建成功-->>'

            }
        }
  }
}
