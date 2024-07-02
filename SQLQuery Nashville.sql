Select * from PortfolioProject.dbo.NashvilleHousing

--STANDARDIZE DATE FORMAT

Select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)



--POPULATE PROPERTY ADDRESS DATA

Select *
from PortfolioProject.dbo.NashvilleHousing
--where propertyaddress is null
order by parcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[uniqueID]<>b.[uniqueID]
where a.PropertyAddress is null

Update a
Set propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[uniqueID]<>b.[uniqueID]
where a.PropertyAddress is null



--BREAKING OUT ADDRESS INTO INDIVIDUAL ADDRESS, CITY, STATE
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where propertyaddress is null
--order by parcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(propertyaddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)

Alter table NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(propertyaddress))

Select owneraddress 
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
from PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

Alter table NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

Alter table NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

Select * 
from PortfolioProject.dbo.NashvilleHousing



--CHANGE Y AND N TO YES AND NO
Select Distinct(Soldasvacant), count(soldasvacant) 
from PortfolioProject.dbo.NashvilleHousing
group by soldasvacant
order by 2

Select soldasvacant
, case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant ='N' then 'No'
		else soldasvacant
		end
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant ='N' then 'No'
		else soldasvacant
		end



--REMOVE DUPLICATES
With RowNumCTE as(
Select * ,
	ROW_NUMBER() over (
	Partition by ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
				UniqueID
				)row_num
from PortfolioProject.dbo.NashvilleHousing
)
Select *
from RowNumCTE
where row_num > 1
--order by propertyaddress



--DELETE UNUSED COLOUMNS
Select * 
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP column owneraddress, taxdistrict, propertyaddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP column SaleDate

