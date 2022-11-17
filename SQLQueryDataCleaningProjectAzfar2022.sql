-- Data Cleaning Using SQL Query

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standardise Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing

-- Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is Null 
Order BY ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null 

-- Breaking out Address into Individual Columns (Address, City,State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END      
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END      

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	   ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
		            PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num >1

-- DELETE UNUSED COLUMNS

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
