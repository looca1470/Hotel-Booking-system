-- phpMyAdmin SQL Dump
-- version 4.7.5
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Creato il: Feb 24, 2018 alle 14:51
-- Versione del server: 5.7.20
-- Versione PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `Booking`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `albergo`
--

CREATE TABLE `albergo` (
  `id_albergo` int(11) NOT NULL,
  `nome` varchar(20) DEFAULT NULL,
  `località` varchar(20) DEFAULT NULL,
  `stelle` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `albergo`
--

INSERT INTO `albergo` (`id_albergo`, `nome`, `località`, `stelle`) VALUES
(1, 'plaza', 'catania', 4),
(3, 'president', 'noto', 3);

-- --------------------------------------------------------

--
-- Struttura della tabella `booking`
--

CREATE TABLE `booking` (
  `id_booking` int(11) NOT NULL,
  `check_in` date NOT NULL,
  `check_out` date NOT NULL,
  `cod_cliente` varchar(20) NOT NULL,
  `cod_camera` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `booking`
--

INSERT INTO `booking` (`id_booking`, `check_in`, `check_out`, `cod_cliente`, `cod_camera`) VALUES
(1, '2018-03-01', '2018-03-21', 'CNT CRL 39B18 F943W', 1),
(2, '2018-02-08', '2018-02-14', 'FZA FBA 90A18 G273H', 2),
(3, '2018-02-18', '2018-02-22', 'LrV GNN 07A01 C351C', 3),
(4, '2018-02-01', '2018-02-02', 'LLV GNN 00A01 C351C', 4);

--
-- Trigger `booking`
--
DELIMITER $$
CREATE TRIGGER `disponibita_camera` BEFORE INSERT ON `booking` FOR EACH ROW BEGIN 
DECLARE y date ; 
SELECT check_out INTO y FROM booking
WHERE NEW.cod_camera = cod_camera LIMIT 1; 

if new.check_in < y  then 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La camera risulta occupata nella data selezionata';
end if; 
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `generatore_pagamento` AFTER INSERT ON `booking` FOR EACH ROW BEGIN DECLARE X int DEFAULT 0; DECLARE Y int DEFAULT 0; 
DECLARE Z int DEFAULT 0; 
SELECT stelle INTO X FROM albergo,booking,camera WHERE NEW.cod_camera = id_camera AND id_albergo = cod_albergo LIMIT 1; 
SELECT count(cod_letto) INTO Y from booking,letti WHERE NEW.cod_camera = id_camera LIMIT 1; 

set Z = (new.check_out - new.check_in)*(30*Y + 80*X); 

insert into preventivo(cod_booking, id_preventivo,prezzo)VALUES(new.id_booking, new.id_booking , z); END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `verifica_data` BEFORE INSERT ON `booking` FOR EACH ROW BEGIN 
DECLARE y date ; 
SELECT check_out INTO y FROM booking
WHERE NEW.cod_camera = cod_camera LIMIT 1; 

if new.check_in > new.check_out  then 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'la data finale non può essere minore di quella iniziale';
end if; 
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `camera`
--

CREATE TABLE `camera` (
  `id_camera` int(11) NOT NULL,
  `cod_albergo` int(11) NOT NULL,
  `id_booking` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `camera`
--

INSERT INTO `camera` (`id_camera`, `cod_albergo`, `id_booking`) VALUES
(1, 1, 1),
(2, 3, 2),
(3, 3, 3),
(4, 3, 4);

-- --------------------------------------------------------

--
-- Struttura della tabella `cliente`
--

CREATE TABLE `cliente` (
  `nome` varchar(20) NOT NULL,
  `cognome` varchar(20) NOT NULL,
  `cf` varchar(20) NOT NULL,
  `indirizzo` varchar(40) NOT NULL,
  `telefono` varchar(13) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `cliente`
--

INSERT INTO `cliente` (`nome`, `cognome`, `cf`, `indirizzo`, `telefono`) VALUES
('carlo', 'conti', 'CNT CRL 39B18 F943W', 'via francesco fusco CT', '3472556799'),
('fabio', 'fazio', 'FZA FBA 90A18 G273H', 'via degli ulivi 11 CT', '3331594532'),
('giovanni', 'allevi', 'LLV GNN 00A01 C351C', 'via dei gatti PA', '3291594566'),
('gino', 'gatti', 'LrV GNN 07A01 C351C', 'via dei topi CL', '3291000066');

-- --------------------------------------------------------

--
-- Struttura della tabella `letti`
--

CREATE TABLE `letti` (
  `cod_letto` int(11) NOT NULL,
  `id_camera` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `letti`
--

INSERT INTO `letti` (`cod_letto`, `id_camera`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 3);

-- --------------------------------------------------------

--
-- Struttura della tabella `preventivo`
--

CREATE TABLE `preventivo` (
  `id_preventivo` int(11) NOT NULL,
  `cod_booking` int(11) NOT NULL,
  `prezzo` decimal(19,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `preventivo`
--

INSERT INTO `preventivo` (`id_preventivo`, `cod_booking`, `prezzo`) VALUES
(1, 1, '7000.0000'),
(2, 2, '1980.0000'),
(3, 3, '1680.0000'),
(4, 4, '240.0000');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `albergo`
--
ALTER TABLE `albergo`
  ADD PRIMARY KEY (`id_albergo`);

--
-- Indici per le tabelle `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`id_booking`),
  ADD UNIQUE KEY `id_booking` (`id_booking`),
  ADD KEY `cod_cliente` (`cod_cliente`),
  ADD KEY `camera_ext` (`cod_camera`),
  ADD KEY `cod_camera` (`cod_camera`);

--
-- Indici per le tabelle `camera`
--
ALTER TABLE `camera`
  ADD PRIMARY KEY (`id_camera`,`cod_albergo`),
  ADD KEY `cod_albergo` (`cod_albergo`);

--
-- Indici per le tabelle `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`cf`);

--
-- Indici per le tabelle `letti`
--
ALTER TABLE `letti`
  ADD PRIMARY KEY (`cod_letto`);

--
-- Indici per le tabelle `preventivo`
--
ALTER TABLE `preventivo`
  ADD PRIMARY KEY (`id_preventivo`,`cod_booking`),
  ADD KEY `cod_booking` (`cod_booking`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `booking`
--
ALTER TABLE `booking`
  MODIFY `id_booking` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `booking_fk` FOREIGN KEY (`cod_cliente`) REFERENCES `cliente` (`cf`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `camera_fk` FOREIGN KEY (`cod_camera`) REFERENCES `camera` (`id_camera`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `camera`
--
ALTER TABLE `camera`
  ADD CONSTRAINT `fk_camera` FOREIGN KEY (`cod_albergo`) REFERENCES `albergo` (`id_albergo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `preventivo`
--
ALTER TABLE `preventivo`
  ADD CONSTRAINT `fk_preventivo` FOREIGN KEY (`cod_booking`) REFERENCES `booking` (`id_booking`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
