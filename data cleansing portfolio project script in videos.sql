/*
	cleaning data in SQL quaries
*/

select * from Portfolio_project.dbo.[Nashville Housing]

--------------------------------------------------------------------------------------------------

--Standardize Date Format

Alter table [Nashville Housing]
add saledateconverted date;

Update [Nashville Housing]
Set saledateconverted =CONVERT(date,saledate)

Select saledateconverted,CONVERT(date,saledate)
from Portfolio_project..[Nashville Housing]

--------------------------------------------------------------------------

--Populate property address data

select *
from Portfolio_project..[Nashville Housing]
where PropertyAddress  is Null
order by ParcelID

select A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
from [Nashville Housing] as A
join [Nashville Housing] as B
on A.ParcelID = B.ParcelID and A.[UniqueID ]<> B.[UniqueID ]
where A.PropertyAddress is Null 

Update A 
SET PropertyAddress=ISNULL(A.PropertyAddress,B.PropertyAddress)
from [Nashville Housing] as A
join [Nashville Housing] as B
on A.ParcelID = B.ParcelID and A.[UniqueID ]<> B.[UniqueID ]
where A.PropertyAddress is Null 

-----------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address,city,state)

select PropertyAddress 
from Portfolio_project..[Nashville Housing]

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from Portfolio_project..[Nashville Housing]

Alter table [Nashville Housing]
Add Propertyspiltaddress nvarchar(255);

Update [Nashville Housing]
Set Propertyspiltaddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table [Nashville Housing]
Add Propertyspilt_city nvarchar(255);

Update [Nashville Housing]
Set Propertyspilt_city =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select owneraddress from [Nashville Housing]
order by ParcelID

select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from [Portfolio_project]..[Nashville Housing]
order by ParcelID

Alter table [Nashville Housing]
add ownersplit_address nvarchar(255);

update [Nashville Housing]
Set ownersplit_address=PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table [Nashville Housing]
add ownersplit_city nvarchar(255);

update [Nashville Housing]
Set ownersplit_city=PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table [Nashville Housing]
add ownersplit_state nvarchar(255);

update [Nashville Housing]
Set ownersplit_state=PARSENAME(Replace(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------

--Change Y and N (some data has been put as Y and N) to Yes and No in "SoldAsVacant" field

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Portfolio_project..[Nashville Housing]
group by SoldAsVacant
order by 2

select SoldAsVacant,
Case
	When SoldAsVacant='Y' then 'Yes'
	When SoldAsVacant='N' then 'No'
	else SoldAsVacant
End
from Portfolio_project..[Nashville Housing]

update [Nashville Housing]
set SoldAsVacant=Case
	When SoldAsVacant='Y' then 'Yes'
	When SoldAsVacant='N' then 'No'
	else SoldAsVacant
End

--------------------------------------------------------------------------------

--Remove duplicate

With Rownumcte as(
select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
			Propertyaddress,
				 saleprice,saledate,
				 legalreference 
				 order by uniqueid	 ) as row_num
from [Nashville Housing]
--order by ParcelID
)

Delete 
from Rownumcte
where row_num>1

-----------------------------------------------------------------------------

--Delete unused columns

select * from Portfolio_project..[Nashville Housing]

Alter table Portfolio_project..[Nashville Housing]
Drop column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate