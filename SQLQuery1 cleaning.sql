
--cleaning data in sql 
select *
from PORTFOLIOPROJECT.dbo.nashvillhousing

--standerdize/change date format 

select SaleDate2, convert(date,saledate)
from PORTFOLIOPROJECT.dbo.nashvillhousing

update nashvillhousing
set saledate = convert(date,saledate)

Alter table nashvillhousing 
add saledate2 date;

update nashvillhousing
set saledate2 = convert(date,saledate)

--populate property address data 

select *
from PORTFOLIOPROJECT.dbo.nashvillhousing
where PropertyAddress is null 
order by ParcelID

select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress,b.PropertyAddress)
from PORTFOLIOPROJECT.dbo.nashvillhousing a
join PORTFOLIOPROJECT.dbo.nashvillhousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null 

 update a
 set PropertyAddress = isnull (a.PropertyAddress,b.PropertyAddress)
 from PORTFOLIOPROJECT.dbo.nashvillhousing a
join PORTFOLIOPROJECT.dbo.nashvillhousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null 
 

  --breaking out addess into individual columns (address ,city,states)

 select PropertyAddress
from PORTFOLIOPROJECT.dbo.nashvillhousing
--where PropertyAddress is null 
--order by ParcelID

select 
substring ( PropertyAddress, 1 ,CHARINDEX (',', PropertyAddress) - 1 ) as address
, substring ( PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, len(propertyaddress)) as address
from PORTFOLIOPROJECT.dbo.nashvillhousing


Alter table nashvillhousing 
add propertsplitaddress Nvarchar(255);

update nashvillhousing
set propertsplitaddress = substring ( PropertyAddress, 1 ,CHARINDEX (',', PropertyAddress) - 1 )


Alter table nashvillhousing 
add propertsplitcity Nvarchar(255);

update nashvillhousing
set propertsplitcity = substring ( PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, len(propertyaddress))

select *
from PORTFOLIOPROJECT.dbo.nashvillhousing

select OwnerAddress
from PORTFOLIOPROJECT.dbo.nashvillhousing

select
PARSENAME(REPLACE(owneraddress, ',', '.') , 3)
,PARSENAME(REPLACE(owneraddress, ',', '.') , 2)
,PARSENAME(REPLACE(owneraddress, ',', '.') , 1)
from PORTFOLIOPROJECT.dbo.nashvillhousing


Alter table nashvillhousing 
add ownersplitaddress Nvarchar(255);

update nashvillhousing
set ownersplitaddress = PARSENAME(REPLACE(owneraddress, ',', '.') , 3)

Alter table nashvillhousing 
add ownersplitcity Nvarchar(255);

update nashvillhousing
set ownersplitcity = PARSENAME(REPLACE(owneraddress, ',', '.') , 2)

Alter table nashvillhousing 
add ownersplitstate Nvarchar(255);

update nashvillhousing
set ownersplitstate = PARSENAME(REPLACE(owneraddress, ',', '.') , 1)

--change y and n to yes and no in "sold as vacant " feild 

select distinct(soldasvacant),count(SoldAsVacant)
from PORTFOLIOPROJECT.dbo.nashvillhousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'y' then 'yes'
        when SoldAsVacant = 'n' then 'no'
		else SoldAsVacant
		end
from PORTFOLIOPROJECT.dbo.nashvillhousing

update nashvillhousing
set SoldAsVacant = case when SoldAsVacant = 'y' then 'yes'
        when SoldAsVacant = 'n' then 'no'
		else SoldAsVacant
		end
--remove duplicate 

with rownumcte as(
select *, 
row_number() over (
partition by ParcelID,
             propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by 
			 uniqueID
			 )ROw_num

from PORTFOLIOPROJECT.dbo.nashvillhousing
)
select *
from rownumcte
where row_num > 1
order by PropertyAddress

--deleting unused columns 

select *
from PORTFOLIOPROJECT.dbo.nashvillhousing

alter table PORTFOLIOPROJECT.dbo.nashvillhousing
drop column owneraddress,taxdistrict,propertyaddress

alter table PORTFOLIOPROJECT.dbo.nashvillhousing
drop column saledate 


