SELECT PersonID AS Person_Id
,V.VisitDate Encounter_Date
,NULL AS Encounter_ID
,CASE WHEN [Cough]=0 THEN 'No'
WHEN [Cough]=1 THEN 'Yes'
END AS [Cough]
,CASE WHEN Fever=0 THEN 'No'
WHEN Fever=1 THEN 'Yes'
END AS Fever
,CASE WHEN WeightLoss=0 THEN 'No'
WHEN WeightLoss=1 THEN 'Yes'
END AS Weight_loss
,CASE WHEN NightSweats=0 THEN 'No'
WHEN NightSweats=1 THEN 'Yes'
END AS Night_sweats
,CASE WHEN ([SputumSmear]>3 and D.ItemName<>'NotDone' and D.ItemName<>'Not Done' )or
([ChestXray]>3 and E.ItemName<>'NotDone' and E.ItemName<>'Not Done')
or ([GeneXpert]>3 and F.ItemName<>'NotDone' ) THEN 'Yes'
ELSE 'No' END AS Tests_Ordered
,D.ItemName Sputum_Smear
,E.ItemName X_ray
,CASE WHEN B.GeneXpert = 0 THEN 'Negative' WHEN B.GeneXpert = 1 THEN 'Positive' WHEN B.GeneXpert = 2 THEN 'Ordered' WHEN B.GeneXpert = 3 THEN 'NotDone' ELSE F.ItemName END Gene_xpert
,[ContactWithTb] Contact_tb_case
,NULL AS Lethergy
,NULL AS Referral
,NULL AS Clinical_diagnosis
,CASE WHEN [InvitationOfContacts]=0 THEN 'No'
WHEN [InvitationOfContacts]=1 THEN 'Yes'
END AS Invitation_contacts
,CASE WHEN [EvaluatedForIpt]=0 THEN 'No'
WHEN [EvaluatedForIpt]=1 THEN 'Yes'
END AS Evaluated_for_IPT
,CASE WHEN (D.ItemName='Negative' OR D.ItemName='Positive' )THEN D.ItemName
WHEN (E.ItemName='Suggestive' OR E.ItemName='Normal' )THEN E.ItemName
WHEN (F.ItemName='Negative' OR F.ItemName='Positive' )THEN F.ItemName
WHEN B.SputumSmear = 0 THEN 'Negative'
WHEN B.SputumSmear = 1 THEN 'Positive'
WHEN B.SputumSmear = 2 THEN 'Ordered'
WHEN B.SputumSmear = 3 THEN 'NotDone'
ELSE NULL END AS TB_results
,A.[CreateDate]created_at
,A.[CreatedBy]created_by
FROM [dbo].[PatientIcf] A
INNER JOIN PATIENT P ON P.ID = A.[PatientId]
INNER JOIN PatientMasterVisit V on V.ID=A.[PatientMasterVisitId] and A.[PatientId]=V.PatientId
LEFT JOIN [dbo].[PatientIcfAction] B ON B.PatientId=A.[PatientId] and B.[PatientMasterVisitId]=A.[PatientMasterVisitId]
LEFT JOIN LookupItemView D on D.ItemID=B.[SputumSmear] and D.MasterName ='SputumSmear'
LEFT JOIN LookupItemView E on E.ItemID=B.[ChestXray] and E.MasterName ='ChestXray'
LEFT JOIN LookupItemView F on F.ItemID=B.[GeneXpert] and F.MasterName ='GeneExpert'
WHERE A.DELETEFLAG=0