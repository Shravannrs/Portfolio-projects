SELECT *
  FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

  --Standardizing date format

  Select SaleDateConverted, CONVERT(Date, SaleDate)
  FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

  UPDATE [Nashville Housing Data for Data Cleaning]
  SET SaleDate=CONVERT(Date,SaleDate)

  Alter table [Nashville Housing Data for Data Cleaning]
  Add SaleDateConverted Date;

  UPDATE [Nashville Housing Data for Data Cleaning]
  SET SaleDateConverted = CONVERT(Date,SaleDate)


------------------


--populate empty property addresses with something
Select *
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
Where PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID
AND a.[UniqueID]<> b.UniqueID
Where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,'no address')
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a 
JOIN PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b 
ON a.ParcelID=b.ParcelID
AND a.[UniqueID]<> b.[UniqueID]
Where a.PropertyAddress is NULL



--populate empty property addresses with something
Select *
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
Where OwnerAddress is NULL
Order by ParcelID

Select a.ParcelID, a.OwnerAddress, b.ParcelID, b.OwnerAddress, ISNULL(a.OwnerAddress,b.OwnerAddress)
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID
AND a.[UniqueID]<> b.UniqueID
Where a.OwnerAddress is null

Update a 
SET OwnerAddress = ISNULL(a.OwnerAddress,'no address')
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a 
JOIN PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b 
ON a.ParcelID=b.ParcelID
AND a.[UniqueID]<> b.[UniqueID]
Where a.OwnerAddress is NULL






---Breaking out addresses into individual columns (Address,City,State)

SELECT PropertyAddress
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]


Alter table [Nashville Housing Data for Data Cleaning]
  Add PropertySplitAddress Nvarchar(255);

  UPDATE [Nashville Housing Data for Data Cleaning]
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)


Alter table [Nashville Housing Data for Data Cleaning]
  Add PropertySplitCity Nvarchar(255);
  UPDATE [Nashville Housing Data for Data Cleaning]
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) +1)
 
---easier way to seperate addresses using parsename

 Select OwnerAddress
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

Alter table [Nashville Housing Data for Data Cleaning]
  Add OwnerSplitAddress Nvarchar(255);

  UPDATE [Nashville Housing Data for Data Cleaning]
  SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table [Nashville Housing Data for Data Cleaning]
  Add OwnerSplitCity Nvarchar(255);

  UPDATE [Nashville Housing Data for Data Cleaning]
  SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

  Alter table [Nashville Housing Data for Data Cleaning]
  Add OwnerSplitState Nvarchar(255);

  UPDATE [Nashville Housing Data for Data Cleaning]
  SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)


  ---Converting the Ys and Ns to Yes or No in the sold as vacant column

  Select Distinct(SoldAsVacant), Count(SoldAsVacant)
  From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
  Group by SoldAsVacant
  Order by 2 

  Select SoldAsVacant,
  case when SoldAsVacant='Y' THEN 'Yes'
  When SoldAsVacant='N' THEN 'No'
  Else SoldAsVacant
  END
  From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

  Update PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
  SET SoldAsVacant=case when SoldAsVacant='Y' THEN 'Yes'
  When SoldAsVacant='N' THEN 'No'
  Else SoldAsVacant
  END



  --Removing duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress





--Deleting unused columns
Select *
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate