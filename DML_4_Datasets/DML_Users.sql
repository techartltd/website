

select u.UserID,u.UserFirstName,u.UserLastName,u.UserName,Status = Case u.DeleteFlag      
    when 0 then 'Active' when 1 then 'InActive' end,ds.[Name] as Designation,ltg.GroupNames    from mst_User u
left join mst_Employee me on me.EmployeeID=u.EmployeeId
left join mst_Designation ds on ds.Id=me.DesignationID
left join (
select  ltu.UserID ,STUFF((select distinct ',' + msg.GroupName from 
 lnk_UserGroup lu
inner join mst_Groups msg on lu.GroupID=msg.GroupID
where lu.UserID=ltu.UserID
for xml path('')),1,1,'') as GroupNames
from lnk_UserGroup ltu
group by ltu.UserID
)ltg on ltg.UserID=u.UserID
where u.UserID != 1;





