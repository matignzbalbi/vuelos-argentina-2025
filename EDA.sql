USE SQLVuelos

SELECT *
FROM Vuelos

---------- Limpieza de datos ---------- 

--- Formateo de Hora

SELECT Hora_UTC,
CONVERT(TIME(0), Hora_UTC) AS HoraFormateada
FROM Vuelos

ALTER TABLE Vuelos
ADD HoraFormateada TIME(0)
UPDATE Vuelos
SET HoraFormateada = CONVERT(TIME(0), Hora_UTC)

--- Chequeo de nulos

--- Limpieza de datos en Aerolínea

SELECT DISTINCT Aerolinea_Nombre
FROM Vuelos
WHERE Aerolinea_Nombre IS NULL
   OR Aerolinea_Nombre = ''
   OR Aerolinea_Nombre = '0';

SELECT COUNT(*) AS CantidadRegistros
FROM Vuelos
WHERE Aerolinea_Nombre = '0';

SELECT 
	Aerolinea_Nombre,
	CASE
		WHEN Aerolinea_Nombre = '0' THEN 'NO INFORMADO'
		ELSE Aerolinea_Nombre
	END AS AerolineaFormateada	
FROM Vuelos

UPDATE Vuelos
SET Aerolinea_Nombre = CASE
							WHEN Aerolinea_Nombre = '0' THEN 'NO INFORMADO'
							ELSE Aerolinea_Nombre
						END

--- Eliminamos columnas innecesarias

ALTER TABLE Vuelos
DROP COLUMN Hora_UTC

ALTER TABLE Vuelos
DROP COLUMN Calidad_dato

--- Limpieza de datos en Aeronave

SELECT DISTINCT Aeronave
FROM Vuelos
WHERE Aeronave IS NULL
   OR Aeronave = ''
   OR Aeronave = '0';

SELECT COUNT(*) AS CantidadRegistros
FROM Vuelos
WHERE Aeronave = '0';

SELECT 
	Aeronave,
	CASE
		WHEN Aeronave = '0' THEN 'NO INFORMADO'
		ELSE Aeronave
	END AS Aeronave	
FROM Vuelos

UPDATE Vuelos
SET Aeronave = CASE
							WHEN Aeronave = '0' THEN 'NO INFORMADO'
							ELSE Aeronave
						END

---------- EDA ---------- 

---- Primer vistazo: Tipo de vuelo y movimiento.

CREATE VIEW vw_ClasificaciónPorVuelo AS
SELECT 
	Clasificación_Vuelo, 
	COUNT(*) AS Cantidad
FROM Vuelos
GROUP BY Clasificación_Vuelo;


CREATE VIEW vw_TipoDeMovimiento AS
SELECT 
	Tipo_de_Movimiento, 
	COUNT(*) AS Cantidad
FROM Vuelos
GROUP BY Tipo_de_Movimiento;

--- Pasajeros por mes 

CREATE VIEW vw_PasajerosPorMes AS
SELECT 
	FORMAT(Fecha_UTC, 'yyyy-MM') AS AñoMes,
	SUM(Pasajeros) AS TotalPasajeros,
	SUM(PAX) AS TotalPax
FROM Vuelos
GROUP BY FORMAT(Fecha_UTC, 'yyyy-MM')

--- Aerolíneas con más pasajeros
CREATE VIEW vw_AerolineasPasajeros AS
SELECT TOP 10
	Aerolinea_Nombre,
	SUM(Pasajeros) AS Pasajeros_Total
FROM Vuelos
GROUP BY Aerolinea_Nombre
ORDER BY Pasajeros_Total DESC

--- Aerolíneas con más pasajeros nacionales (PAX)
CREATE VIEW vw_AerolineasPasajerosDomesticos AS
SELECT TOP 10
	Aerolinea_Nombre,
	SUM(PAX) AS Pasajeros_Total
FROM Vuelos
GROUP BY Aerolinea_Nombre
ORDER BY Pasajeros_Total DESC


--- Clasificación de vuelo por Aerolínea

--- Internacionales
CREATE VIEW vw_AerolineaVuelosInt AS
SELECT TOP 10
	Aerolinea_Nombre,
	COUNT(*) AS CantidadInternacionales
FROM Vuelos
WHERE Clasificación_Vuelo = 'Internacional'
GROUP BY Aerolinea_Nombre
ORDER BY CantidadInternacionales DESC

--- Nacionales 
CREATE VIEW vw_AerolineasVuelosNac AS
SELECT TOP 10
	Aerolinea_Nombre,
	COUNT(*) AS CantidadNacionales
FROM Vuelos
WHERE Clasificación_Vuelo = 'Doméstico'
GROUP BY Aerolinea_Nombre
ORDER BY CantidadNacionales DESC

--- Promedio de pasajeros por Aeronave 
CREATE VIEW vw_AvgAeronave AS
SELECT TOP 10
	Aeronave,
	AVG(Pasajeros) AS PromedioPasajeros
FROM Vuelos
GROUP BY Aeronave
ORDER BY PromedioPasajeros DESC

--- Aeropuertos con mayor frecuencia de aterrizaje
CREATE VIEW vw_FrecuenciaAterrizaje AS
SELECT TOP 10
	Aeropuerto,
	COUNT(*) AS CantidadAterrizajes
FROM Vuelos
WHERE Tipo_de_Movimiento = 'Aterrizaje'
GROUP BY Aeropuerto
ORDER BY CantidadAterrizajes DESC

--- Aeropuertos con mayor frecuencia de despegue
CREATE VIEW vw_FrecuenciaDespegue AS
SELECT TOP 10
	Aeropuerto,
	COUNT(*) AS CantidadDespegues
FROM Vuelos
WHERE Tipo_de_Movimiento = 'Despegue'
GROUP BY Aeropuerto
ORDER BY CantidadDespegues DESC

--- Aeropuertos con mayor frecuencia destino
CREATE VIEW vw_FrecuenciaDestino AS
SELECT TOP 10
	Origen_Destino,
	COUNT(*) AS Frecuencia
FROM Vuelos
GROUP BY Origen_Destino
ORDER BY Frecuencia DESC

--- Cantidad de pasajeros mensuales por clasificación de vuelo

CREATE VIEW vw_PasajerosPorClasVuelo AS
WITH VuelosConAñoMes AS (
  SELECT 
    FORMAT(Fecha_UTC, 'yyyy-MM') AS AñoMes,
    Aerolinea_Nombre,
    Clasificación_Vuelo,
    Pasajeros,
    PAX
  FROM Vuelos
)
SELECT 
  AñoMes,
  Clasificación_Vuelo,
  SUM(Pasajeros) AS TotalPasajeros
FROM VuelosConAñoMes
GROUP BY AñoMes, Clasificación_Vuelo

