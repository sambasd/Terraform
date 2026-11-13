stage('Ansible Configuration') {
    steps {
        sh '''
            set -e
            export ANSIBLE_HOST_KEY_CHECKING=False

            cd /opt/ansible-project

            echo "Testing server connectivity..."
            /usr/local/bin/ansible -i inventory.ini rhel_servers -m ping

            echo "Creating Linux users..."
            /usr/local/bin/ansible-playbook -i inventory.ini users.yml

            echo "Configuring filesystems..."
            /usr/local/bin/ansible-playbook -i inventory.ini filesystem.yml

            echo "Configuring swap..."
            /usr/local/bin/ansible-playbook -i inventory.ini swap.yml

            echo "Installing agents..."
            /usr/local/bin/ansible-playbook -i inventory.ini agents.yml

            echo "Configuring CloudWatch..."
            /usr/local/bin/ansible-playbook -i inventory.ini cloudwatch-agent.yml

            echo "All Ansible playbooks completed!"
        '''
    }
}
