## 题目
- 1.在linux4 上安装 ansible，作为 ansible 的控制节点。Linux1-linux7作为 ansible 的受控节点。
- 2.编写/root/my.yml 剧本，实现在 linux2 的/root 目录创建一个 ansible.txt 文件，写入“ChinaSkills”，然后复制到所有受控节点的/root 目录。
  

## 答案
# 在 Linux4 上生成 SSH 密钥（如果尚未生成）

```shell
ssh-keygen -t rsa
```

# 将公钥复制到所有受控节点
```
for node in linux1 linux2 linux3 linux4 linux5 linux6 linux7; do
  ssh-copy-id root@$node
done
```


# 创建剧本文件
```shell
vi /root/my.yml

---
- name: create file in linux2
  hosts: linux2.skills.com
  become: yes

  tasks:
    - name: 
      copy:
        dest: /root/ansible.txt
        content: "ChinaSkills"
      
    - name:
      shell: scp /root/ansible.txt root@linux1.skills.com:/root
      delegate_to: linux2.skills.com
    - name:
      shell: scp /root/ansible.txt root@linux3.skills.com:/root
      delegate_to: linux2.skills.com
    - name:
      shell: scp /root/ansible.txt root@linux4.skills.com:/root
      delegate_to: linux2.skills.com
    - name:
      shell: scp /root/ansible.txt root@linux5.skills.com:/root
      delegate_to: linux2.skills.com
    - name:
      shell: scp /root/ansible.txt root@linux6.skills.com:/root
      delegate_to: linux2.skills.com
    - name:
      shell: scp /root/ansible.txt root@linux7.skills.com:/root
      delegate_to: linux2.skills.com


```


