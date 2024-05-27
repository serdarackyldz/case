## Infrastructure Setup

 **Kubernetes Cluster Kurulumu**

VMware Workstation üzerinde 1 adet template RockyLinux-9.3 kuruldu.

Bu template clonelanarak 1 master - 1 worker node'lu Kubernetes cluster'ı kurulumu gerçekleştirildi:

- Kullanılacak olan template üzerinde upgrade-update firewall ve selinux configler düzenlendi.
- Makineler statik IP üzerinden bridge network ile konfigüre edildi.
- Template üzerinde host dosyasına DNS ile geçiş için master-worker IP'leri eklendi.
- Makineler arası ssh key paylaşımı yapıldı. (ssh-generate-share.sh)
  
  Ansible playbook'u hazırlanarak aşağıdaki işlemler gerçekleştirildi:
- Master makinesinde rke2-server kuruldu ve rke2-server.service enable ve start edildi.
- Worker node üzerinde rke2-agent kuruldu ve rke2-agent.service enable ve start edildi. 
- Worker node cluster'a join olması için gereken node-token master üzerinden alınarak agent üzerinde kullanıldı.


**Helm Installation: https://helm.sh/docs/intro/install/ \
**Kubectl Installation: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

 **Monitoring Altyapısının Kurulumu**

Monitoring ihtiyaçları için production ortamlarında kullandığım prometheus-grafana-stack HELM ile kurulumu yapıldı.
Bu HELM pull edildi ve repo üzerinde mevcuttur.

- prometheus-grafana-stack isimli namespace oluşturuldu.
- Prometheus'a ait service NodePort olarak şekilde açıldı. 
- Alertmanager grafana alerting üzerinde yönetilecek dashboard'lar oluşturuldu.
- Oluşan bu alarmlar'a label olarak severity oluşturuldu burada en çok kullanılan 3 opsiyon oluşturuldu. (Critical-Error-Info)

**Prometheus-NodeExporter-Alertmanager:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

Monitoring Stack için kullanılan ansible playbook'u da repository'ye eklenmiştir.

**Python Web Yazılımı**

Basit bir web sayfası kodu python ile yazıldı.

Bu kodun containerize olabilmesi için multistage Dockerfile hazırlandı. Dockerfile hazırlanırken resource utilization ve imaj boyutuna dikkat edildi.

 **CI/CD Altyapısının Kurulumu**

CI/CD ihtiyaçları için Jenkins deploymentı yapıldı. Jenkins için kullanılan ansible playbook'u da repository'ye eklenmiştir.

Jenkins üzerinde çalışması planlanan pipeline için Jenkinsfile hazırlandı.

https://github.com/serdarackyldz/case/blob/main/screenshots/Jenkins.png
