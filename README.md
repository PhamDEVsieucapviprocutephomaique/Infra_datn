học chủ về về azure terraform  
tóm gọn bao gồm : mô hình hub -spoke  
tóm gọn theo ý hiểu

hub : bastion, firewall,applicationgateway

spoke(aks,acr,vm(kafka) postgresql

theo layer 7 tầng :  
network : tạo các vm hub - vm spoke , tạo peering vmhub-vmspoke, tạo subnet các resource trong hub và spoke  
security : tạo các rule inboud chỉ nhận https  
firewall: theo kiến trúc firewall cho oubout applicationgateway cho inbound:

setup public ip firewall, tạo policy, gán policy gồm các rule như networkrule

: oubout đến dns ,ntp , ngoài ra application rule(tầng7 osi) đến các fqdn của microsoft ( k8s kéo acr,entraid,...), bastion cấu hình gồm 1 public ip: nhằm ssh vào các resource an toàn hơn đi thẳng qua appilicaton gateway,  
bước cuối gán routable cho các resource

aks : cấu hình gồm systemm_pool,app_pool,cron_job_pool: rất phức tạp : đọc cũng chưa hiểu lắm =)): tóm gọn gồm 1 identity để vào acr được, và cấu hình cơ bản mỗi pool gồm : các node highpa,..)

application gateway : tương tự cần 1 public ip, sau đó tạo 1 policy gồm nhiều rule và chuyển đổi http- https,.ssl,..  
cuối cùng chuyển trafic từ intern đến ip của app_pool k8s(ingress, sau đó từ ingress sẽ phân giải kết hợp với loadblance đưa vào các pod tương ứng )

##############################################
