--Cleaning data in SQL Sueries

Select * From NashvileHousing


--Standardize date format

Select SaleDate, CONVERT(Date, SaleDate)
From NashvileHousing

Update NashvileHousing
SET SaleDate = CONVERT(Date, SaleDate)

Alter table NashvileHousing
Add SaleDateConverted Date;

Update NashvileHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From NashvileHousing

--Populate Property Address
Select *
From NashvileHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvileHousing as a
JOIN NashvileHousing as b
	 on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvileHousing as a
JOIN NashvileHousing as b
	 on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking uot Address into indivisual coloumns (Address, City, State)

Select PropertyAddress
From NashvileHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From NashvileHousing

Alter Table NashvileHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

Alter Table NashvileHousing
Add PropertySplitCity Nvarchar(255);

Update NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Now lets we split OwnerAddress wit different method

Select OwnerAddress
From NashvileHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.') , 3)
, PARSENAME(Replace(OwnerAddress, ',', '.') , 2)
, PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
From NashvileHousing

Alter Table NashvileHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvileHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)

Alter Table NashvileHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvileHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2)

Alter Table NashvileHousing
Add OwnerSplitStates Nvarchar(255);

Update NashvileHousing
SET OwnerSplitStates = PARSENAME(Replace(OwnerAddress, ',', '.') , 1)


--Change Y and N to Yes amd No in SoldasVacant Field

Select Distinct(SoldAsVacant), Count(SoldASVacant)
From NashvileHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From NashvileHousing

Update NashvileHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = ' No' Then 'No'
	   ELSE SoldAsVacant
	   END


--Remove Duplicates (Using CTE and windows function)

--Pertama2 cari dulu mana aja row yang duplicate ditandain dgn kolomn rum_num2, pake CTE
Select *,
	ROW_NUMBER() OVER(
	Partition BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num 
From NashvileHousing
Order BY ParcelId

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	Partition BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num 
From NashvileHousing
--Order BY ParcelId
)
Select *
From RowNumCTE
Where row_num > 1 
Order BY PropertyAddress

--Baru itu di hapus pake fungction ini, yg sebenernya sama kaya diatas tapi cuma Ganti function Select di paling bawah jadi Delete
With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	Partition BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num 
From NashvileHousing
--Order BY ParcelId
)
Delete
From RowNumCTE
Where row_num > 1 
--Order BY PropertyAddress


--DELETE UNUSED COLOUMN
Alter table NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





