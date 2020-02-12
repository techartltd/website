-- 2. Triage
 DECLARE @BlueCardVitals int, @BlueCardVitalsNotMapped int, @GreencardVitals int, @TotalsVitals int

--Bluecard Triage
SELECT @BlueCardVitals = COUNT(*) FROM dtl_PatientVitals
SELECT @BlueCardVitalsNotMapped = COUNT(*) FROM dtl_PatientVitals WHERE Ptn_Pk = 0

--Greencard Triage
SELECT @GreencardVitals = COUNT(*) FROM PatientVitals

--triage stats
SELECT @BlueCardVitals BlueCardVitals, @BlueCardVitalsNotMapped BlueCardVitalsNotMapped, @GreencardVitals GreencardVitals, (@BlueCardVitals - @BlueCardVitalsNotMapped + @GreencardVitals) TotalVitals

