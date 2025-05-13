SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

--- Modify date format 

-- SaleDate contains time too. Keep just date.

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------

--- Populate Property Address data

--the PropertyAddress column is empty in some rows, but they seem to be duplicates of some other properties
--populate it with data FROM identical ParcelIDs

SELECT COUNT(*) 
FROM NashvilleHousing 
WHERE PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------------------

--- Break out Address into Individual Columns (Address, City, State)

ALTER TABLE NashvilleHousing
ADD Property_Address NVARCHAR(225);

UPDATE NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress,1,INSTR(PropertyAddress,',') - 1);

ALTER TABLE NashvilleHousing
ADD Property_City NVARCHAR(225);

UPDATE NashvilleHousing
SET Property_City = SUBSTRING(PropertyAddress,INSTR(PropertyAddress,',') + 1, LENGTH(PropertyAddress));

-- do the same with OwnerAddress


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD Owner_Address Nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD Owner_City Nvarchar(255);

UPDATE NashvilleHousing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD Owner_State Nvarchar(255);

UPDATE NashvilleHousing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)







--------------------------------------------------------------------------------------------------------------------------


--- Change Y and N to Yes and No in SoldAsVacant column 


SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






--------------------------------------------------------------------------------------------------------------------------

--- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------






--------------------------------------------------------------------------------------------------------------------------

--- Delete Unused Columns


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
