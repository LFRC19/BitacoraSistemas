-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: carnes_bacal
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `anuncios`
--

DROP TABLE IF EXISTS `anuncios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `anuncios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(200) NOT NULL,
  `contenido` text NOT NULL,
  `tipo` enum('info','aviso','urgente','exito') NOT NULL DEFAULT 'info',
  `icono` varchar(50) DEFAULT 'megaphone',
  `sucursal_id` int(11) DEFAULT NULL,
  `rol_id` int(11) DEFAULT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date DEFAULT NULL COMMENT 'NULL = sin fecha límite',
  `fijado` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = se fija arriba',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_por_id` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_activo_vigencia` (`activo`,`fecha_inicio`,`fecha_fin`),
  KEY `idx_sucursal` (`sucursal_id`),
  KEY `idx_rol` (`rol_id`),
  KEY `fk_anun_creador` (`creado_por_id`),
  CONSTRAINT `fk_anun_creador` FOREIGN KEY (`creado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_anun_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_anun_sucursal` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursales` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `anuncios`
--

LOCK TABLES `anuncios` WRITE;
/*!40000 ALTER TABLE `anuncios` DISABLE KEYS */;
INSERT INTO `anuncios` VALUES (1,'NUEVA ACTUALIZACION','Se ingresan cambios de fase 16, se aproxima versión 2.0.','info','megaphone',NULL,NULL,'2026-05-24','2026-05-25',1,1,1,'2026-05-25 01:38:23','2026-05-25 01:38:23');
/*!40000 ALTER TABLE `anuncios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `anuncios_lecturas`
--

DROP TABLE IF EXISTS `anuncios_lecturas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `anuncios_lecturas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `anuncio_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `leido_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_anuncio_usuario` (`anuncio_id`,`usuario_id`),
  KEY `idx_usuario` (`usuario_id`),
  CONSTRAINT `fk_lect_anuncio` FOREIGN KEY (`anuncio_id`) REFERENCES `anuncios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lect_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `anuncios_lecturas`
--

LOCK TABLES `anuncios_lecturas` WRITE;
/*!40000 ALTER TABLE `anuncios_lecturas` DISABLE KEYS */;
/*!40000 ALTER TABLE `anuncios_lecturas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `areas`
--

DROP TABLE IF EXISTS `areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `areas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `color` varchar(20) DEFAULT '#6B7280',
  `icono` varchar(50) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime DEFAULT current_timestamp(),
  `actualizado_en` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `areas`
--

LOCK TABLES `areas` WRITE;
/*!40000 ALTER TABLE `areas` DISABLE KEYS */;
INSERT INTO `areas` VALUES (1,'Cajas',NULL,'#D97706',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(2,'Contabilidad',NULL,'#DC2626',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(3,'Gerencia',NULL,'#2563EB',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(4,'Auditoría',NULL,'#7C3AED',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(5,'Almacén',NULL,'#9333EA',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(6,'Pedidos',NULL,'#EA580C',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(7,'Seguridad e Higiene',NULL,'#16A34A',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(8,'Diseño',NULL,'#22C55E',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(9,'RH',NULL,'#6B7280',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(10,'Reparto',NULL,'#EA580C',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(11,'Carnicería',NULL,'#2563EB',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(12,'Cuarto Frío',NULL,'#D97706',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(13,'Mantenimiento',NULL,'#6B7280',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(14,'Proyectos Especiales',NULL,'#7C3AED',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(15,'Oficina',NULL,'#6B7280',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(16,'Cocina',NULL,'#16A34A',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(17,'Guardias',NULL,'#9333EA',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(18,'Taller',NULL,'#DC2626',NULL,1,'2026-05-20 13:52:18','2026-05-20 13:52:18'),(19,'Sistemas','Área de Sistemas y Soporte técnico del Grano de Oro','#10B981',NULL,1,'2026-05-21 14:06:35','2026-05-21 14:06:35');
/*!40000 ALTER TABLE `areas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_sistema`
--

DROP TABLE IF EXISTS `auditoria_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria_sistema` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `accion` varchar(100) NOT NULL,
  `entidad` varchar(50) DEFAULT NULL,
  `entidad_id` int(11) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `creado_en` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `idx_accion` (`accion`),
  KEY `idx_fecha` (`creado_en`),
  CONSTRAINT `auditoria_sistema_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_sistema`
--

LOCK TABLES `auditoria_sistema` WRITE;
/*!40000 ALTER TABLE `auditoria_sistema` DISABLE KEYS */;
INSERT INTO `auditoria_sistema` VALUES (1,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 15:03:42'),(2,1,'cambio_password','usuarios',1,'Cambio de contraseña','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 15:03:58'),(3,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:44:42'),(4,2,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:45:02'),(5,2,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:45:38'),(6,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:45:45'),(7,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:46:38'),(8,5,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:47:01'),(9,5,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:47:24'),(10,7,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:47:38'),(11,7,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:48:15'),(12,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:55:42'),(13,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:56:32'),(14,2,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:56:43'),(15,2,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 17:57:11'),(16,5,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:14:14'),(17,5,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:14:53'),(18,2,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:15:00'),(19,2,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:18:57'),(20,5,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:19:04'),(21,5,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:19:22'),(22,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:19:36'),(23,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:19:41'),(24,2,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:19:52'),(25,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:25:18'),(26,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:26:01'),(27,5,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:26:19'),(28,5,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:27:20'),(29,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:29:45'),(30,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:32:39'),(31,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:37:01'),(32,5,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:37:08'),(33,5,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 18:37:12'),(34,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 08:46:33'),(35,1,'crear_incidencia','incidencias',81,'Folio INC-BAC-2026-0044','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 08:50:34'),(36,1,'crear_incidencia','incidencias',82,'Folio INC-BAC-2026-0045','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 08:55:30'),(37,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 08:58:26'),(38,2,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 08:58:34'),(39,2,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 09:07:58'),(40,5,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 09:08:24'),(41,5,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 09:08:48'),(42,6,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 09:10:22'),(43,6,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 09:35:47'),(44,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:01:38'),(45,1,'crear_usuario','usuarios',10,'Usuario lfrodriguez creado','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:04:05'),(46,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:04:40'),(47,10,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:04:52'),(48,10,'cambio_password','usuarios',10,'Cambio de contraseña','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:05:13'),(49,10,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:05:40'),(50,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:05:51'),(51,1,'crear_area','areas',19,'Área Sistemas','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:06:35'),(52,1,'crear_subcategorias','subcategorias',19,'Subcategoría Instalación','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:08:57'),(53,1,'exportar_incidencia_pdf','incidencias',82,'Exportó INC-BAC-2026-0045 a PDF','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:35:52'),(54,1,'exportar_incidencia_pdf','incidencias',81,'Exportó INC-BAC-2026-0044 a PDF','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 14:36:11'),(55,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 15:24:09'),(56,2,'cambio_password','usuarios',2,'Cambio de contraseña','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 15:24:30'),(57,2,'logout',NULL,NULL,'Cierre de sesión','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 15:24:36'),(58,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 15:24:45'),(59,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 15:35:22'),(60,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 16:15:19'),(61,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 19:03:53'),(62,10,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 09:38:58'),(63,10,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 09:39:37'),(64,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 17:02:07'),(65,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 22:07:33'),(66,10,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 22:07:45'),(67,10,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 22:08:43'),(68,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 22:08:53'),(69,1,'editar_usuario','usuarios',10,'Usuario lfrodriguez editado','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 22:20:55'),(70,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 22:31:09'),(71,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 12:09:51'),(72,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 12:10:02'),(73,1,'generar_backup',NULL,NULL,'Backup manual generado: backup_2026-05-23_122007.sql.gz (19.4 KB, método: mysqldump)','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 12:20:07'),(74,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 08:41:06'),(75,10,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 08:41:18'),(76,10,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 08:42:12'),(77,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 08:42:19'),(78,1,'crear_incidencia','incidencias',83,'Folio INC-BAC-2026-0046','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 08:47:19'),(79,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:10:32'),(80,10,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:11:01'),(81,10,'crear_incidencia','incidencias',84,'Folio INC-BAC-2026-0047','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:11:56'),(82,10,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:17:24'),(83,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:17:31'),(84,1,'generar_backup',NULL,NULL,'Backup manual generado: backup_2026-05-24_131737.sql.gz (21.2 KB, método: mysqldump)','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:17:38'),(85,1,'descargar_backup','backups_realizados',3,'Descargó backup backup_2026-05-24_131737.sql.gz','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:17:41'),(86,1,'crear_incidencia','incidencias',85,'Folio INC-BAC-2026-0048','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:22:21'),(87,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:25:11'),(88,1,'archivar_masivo',NULL,NULL,'Archivado masivo: 11 incidencia(s) resueltas hace >30 días','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:41:25'),(89,1,'crear_regla','reglas_asignacion',1,'Regla Urgencia','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 18:11:54'),(90,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 18:23:58'),(91,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 18:34:12'),(92,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 18:34:22'),(93,1,'crear_anuncio','anuncios',1,'Anuncio: NUEVA ACTUALIZACION','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 18:38:23'),(94,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:30:27'),(95,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:30:52'),(96,2,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:30:58'),(97,2,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:32:24'),(98,10,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:32:37'),(99,2,'logout',NULL,NULL,'Cierre de sesión','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:32:54'),(100,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:32:59'),(101,10,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:33:09'),(102,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:33:14'),(103,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:36:35'),(104,2,'logout',NULL,NULL,'Cierre de sesión','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:40:44'),(105,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','2026-05-25 08:41:06'),(106,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:42:10'),(107,2,'logout',NULL,NULL,'Cierre de sesión','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','2026-05-25 08:50:09'),(108,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','2026-05-25 08:50:12'),(109,2,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 08:51:07'),(110,1,'subir_plano','sucursales',1,'Plano: uploads/planos/plano_1_1779725269.png','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:07:49'),(111,1,'crear_planta','sucursal_plantas',2,'Planta: Oficinas','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:23:39'),(112,1,'subir_plano','sucursal_plantas',2,'Plano: uploads/planos/plano_p2_1779726235.png','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:23:55'),(113,1,'crear_planta','sucursal_plantas',3,'Planta: 3er Piso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:24:06'),(114,1,'subir_plano','sucursal_plantas',3,'Plano: uploads/planos/plano_p3_1779726256.png','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:24:16'),(115,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:27:02'),(116,10,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:27:16'),(117,10,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:28:03'),(118,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:28:13'),(119,1,'editar_sucursal','sucursales',2,'Sucursal Ferias','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:35:41'),(120,1,'editar_sucursal','sucursales',1,'Sucursal Bacal','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 09:35:53'),(121,1,'desactivar','usuarios',8,'Desactivación de Usuario jefe_carn','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 11:06:08'),(122,1,'activar','usuarios',8,'Activación de Usuario jefe_carn','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 11:06:21'),(123,2,'logout',NULL,NULL,'Cierre de sesión','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 11:07:06'),(124,1,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 11:07:26'),(125,1,'cerrar_todas_sesiones','usuarios',2,'Admin cerró todas las sesiones (4) del usuario abraham','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 11:08:37'),(126,1,'editar_usuario','usuarios',2,'Usuario abraham editado','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 11:08:45'),(127,1,'editar_usuario','usuarios',5,'Usuario gerente1 editado','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 11:11:36'),(128,1,'editar_usuario','usuarios',6,'Usuario gerente2 editado','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 11:13:59'),(129,1,'crear_usuario','usuarios',11,'Usuario jlcorral creado','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 11:20:16'),(130,1,'login',NULL,NULL,'Inicio de sesión exitoso','100.109.40.60','Mozilla/5.0 (iPhone; CPU iPhone OS 26_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/148.0.7778.166 Mobile/15E148 Safari/604.1','2026-05-25 11:45:20'),(131,1,'logout',NULL,NULL,'Cierre de sesión','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 13:05:03'),(132,1,'login',NULL,NULL,'Inicio de sesión exitoso','192.168.1.54','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 14:02:02'),(133,1,'login',NULL,NULL,'Inicio de sesión exitoso','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-25 15:39:28'),(134,1,'login',NULL,NULL,'Inicio de sesión exitoso','100.109.40.60','Mozilla/5.0 (iPhone; CPU iPhone OS 26_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/148.0.7778.166 Mobile/15E148 Safari/604.1','2026-05-25 15:53:13');
/*!40000 ALTER TABLE `auditoria_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backups_realizados`
--

DROP TABLE IF EXISTS `backups_realizados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `backups_realizados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_archivo` varchar(255) NOT NULL,
  `tamano_bytes` bigint(20) NOT NULL DEFAULT 0,
  `tipo` enum('manual','automatico') NOT NULL DEFAULT 'manual',
  `realizado_por_id` int(11) DEFAULT NULL COMMENT 'Null si fue automatico',
  `notas` varchar(255) DEFAULT NULL,
  `exitoso` tinyint(1) NOT NULL DEFAULT 1,
  `mensaje_error` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_creado` (`creado_en`),
  KEY `fk_backup_usuario` (`realizado_por_id`),
  CONSTRAINT `fk_backup_usuario` FOREIGN KEY (`realizado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backups_realizados`
--

LOCK TABLES `backups_realizados` WRITE;
/*!40000 ALTER TABLE `backups_realizados` DISABLE KEYS */;
INSERT INTO `backups_realizados` VALUES (1,'backup_2026-05-23_122007.sql.gz',19891,'manual',1,NULL,1,NULL,'2026-05-23 19:20:07'),(2,'backup_2026-05-23_122159.sql.gz',19993,'automatico',NULL,'Backup automático programado',1,NULL,'2026-05-23 19:22:00'),(3,'backup_2026-05-24_131737.sql.gz',21720,'manual',1,NULL,1,NULL,'2026-05-24 20:17:38');
/*!40000 ALTER TABLE `backups_realizados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categorias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `color` varchar(20) DEFAULT '#6B7280',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Hardware',NULL,'#DC2626',1,'2026-05-20 13:52:18'),(2,'Software',NULL,'#2563EB',1,'2026-05-20 13:52:18'),(3,'Red e Internet',NULL,'#16A34A',1,'2026-05-20 13:52:18'),(4,'Telefonía',NULL,'#7C3AED',1,'2026-05-20 13:52:18'),(5,'Seguridad',NULL,'#EA580C',1,'2026-05-20 13:52:18'),(6,'Punto de Venta',NULL,'#D97706',1,'2026-05-20 13:52:18'),(7,'Cámaras CCTV',NULL,'#9333EA',1,'2026-05-20 13:52:18'),(8,'Alarmas',NULL,'#DC2626',1,'2026-05-20 13:52:18'),(9,'Impresión',NULL,'#6B7280',1,'2026-05-20 13:52:18'),(10,'Soporte a usuario',NULL,'#22C55E',1,'2026-05-20 13:52:18'),(11,'Mantenimiento',NULL,'#0EA5E9',1,'2026-05-20 13:52:18'),(12,'Otro',NULL,'#6B7280',1,'2026-05-20 13:52:18');
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias_palabras_clave`
--

DROP TABLE IF EXISTS `categorias_palabras_clave`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categorias_palabras_clave` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `categoria_id` int(11) NOT NULL,
  `palabra` varchar(60) NOT NULL COMMENT 'Palabra o frase clave (lowercase, sin acentos)',
  `peso` int(11) NOT NULL DEFAULT 1 COMMENT 'Mayor peso = más específica',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cat_palabra` (`categoria_id`,`palabra`),
  KEY `idx_palabra` (`palabra`),
  CONSTRAINT `fk_kw_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias_palabras_clave`
--

LOCK TABLES `categorias_palabras_clave` WRITE;
/*!40000 ALTER TABLE `categorias_palabras_clave` DISABLE KEYS */;
INSERT INTO `categorias_palabras_clave` VALUES (1,1,'computadora',2,'2026-05-24 20:30:05'),(2,1,'compu',1,'2026-05-24 20:30:05'),(3,1,'pc',1,'2026-05-24 20:30:05'),(4,1,'laptop',2,'2026-05-24 20:30:05'),(5,1,'monitor',2,'2026-05-24 20:30:05'),(6,1,'pantalla',1,'2026-05-24 20:30:05'),(7,1,'teclado',2,'2026-05-24 20:30:05'),(8,1,'mouse',2,'2026-05-24 20:30:05'),(9,1,'raton',1,'2026-05-24 20:30:05'),(10,1,'cable',1,'2026-05-24 20:30:05'),(11,1,'cargador',2,'2026-05-24 20:30:05'),(12,1,'fuente',1,'2026-05-24 20:30:05'),(13,1,'disco duro',2,'2026-05-24 20:30:05'),(14,1,'memoria',1,'2026-05-24 20:30:05'),(15,1,'puerto usb',2,'2026-05-24 20:30:05'),(16,1,'no enciende',2,'2026-05-24 20:30:05'),(17,1,'no prende',2,'2026-05-24 20:30:05'),(32,9,'impresora',3,'2026-05-24 20:30:05'),(33,9,'imprimir',2,'2026-05-24 20:30:05'),(34,9,'imprime',2,'2026-05-24 20:30:05'),(35,9,'ticket',1,'2026-05-24 20:30:05'),(36,9,'tickets',1,'2026-05-24 20:30:05'),(37,9,'toner',3,'2026-05-24 20:30:05'),(38,9,'tinta',2,'2026-05-24 20:30:05'),(39,9,'cartucho',3,'2026-05-24 20:30:05'),(40,9,'papel',1,'2026-05-24 20:30:05'),(41,9,'atasco',2,'2026-05-24 20:30:05'),(47,6,'pos',3,'2026-05-24 20:30:05'),(48,6,'caja',2,'2026-05-24 20:30:05'),(49,6,'cobro',2,'2026-05-24 20:30:05'),(50,6,'venta',1,'2026-05-24 20:30:05'),(51,6,'cobrar',2,'2026-05-24 20:30:05'),(52,6,'terminal',1,'2026-05-24 20:30:05'),(53,6,'lector',1,'2026-05-24 20:30:05'),(54,6,'codigo de barras',3,'2026-05-24 20:30:05'),(55,6,'scanner',2,'2026-05-24 20:30:05'),(56,6,'sistema de cobro',3,'2026-05-24 20:30:05'),(62,3,'internet',3,'2026-05-24 20:30:05'),(63,3,'red',2,'2026-05-24 20:30:05'),(64,3,'wifi',3,'2026-05-24 20:30:05'),(65,3,'wi-fi',3,'2026-05-24 20:30:05'),(66,3,'router',3,'2026-05-24 20:30:05'),(67,3,'modem',3,'2026-05-24 20:30:05'),(68,3,'cable de red',3,'2026-05-24 20:30:05'),(69,3,'ethernet',2,'2026-05-24 20:30:05'),(70,3,'sin conexion',3,'2026-05-24 20:30:05'),(71,3,'sin internet',3,'2026-05-24 20:30:05'),(72,3,'lento',1,'2026-05-24 20:30:05'),(73,3,'no conecta',2,'2026-05-24 20:30:05'),(77,2,'software',3,'2026-05-24 20:30:05'),(78,2,'sistema',2,'2026-05-24 20:30:05'),(79,2,'aplicacion',2,'2026-05-24 20:30:05'),(80,2,'programa',2,'2026-05-24 20:30:05'),(81,2,'app',1,'2026-05-24 20:30:05'),(82,2,'error',1,'2026-05-24 20:30:05'),(83,2,'congelado',2,'2026-05-24 20:30:05'),(84,2,'pantalla azul',3,'2026-05-24 20:30:05'),(85,2,'cierra solo',3,'2026-05-24 20:30:05'),(86,2,'no abre',2,'2026-05-24 20:30:05'),(87,2,'actualizacion',2,'2026-05-24 20:30:05'),(88,2,'update',1,'2026-05-24 20:30:05');
/*!40000 ALTER TABLE `categorias_palabras_clave` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comentario_reacciones`
--

DROP TABLE IF EXISTS `comentario_reacciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comentario_reacciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `comentario_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `emoji` varchar(10) NOT NULL COMMENT 'Emoji unicode',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_react` (`comentario_id`,`usuario_id`,`emoji`),
  KEY `idx_comentario` (`comentario_id`),
  KEY `fk_react_usuario` (`usuario_id`),
  CONSTRAINT `fk_react_comentario` FOREIGN KEY (`comentario_id`) REFERENCES `incidencias_comentarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_react_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comentario_reacciones`
--

LOCK TABLES `comentario_reacciones` WRITE;
/*!40000 ALTER TABLE `comentario_reacciones` DISABLE KEYS */;
INSERT INTO `comentario_reacciones` VALUES (1,2,1,'👍','2026-05-25 15:30:19');
/*!40000 ALTER TABLE `comentario_reacciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipo_fotos`
--

DROP TABLE IF EXISTS `equipo_fotos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipo_fotos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `equipo_id` int(11) NOT NULL,
  `ruta` varchar(255) NOT NULL COMMENT 'Ruta relativa (assets/equipos/...)',
  `descripcion` varchar(255) DEFAULT NULL,
  `es_portada` tinyint(1) NOT NULL DEFAULT 0,
  `subido_por_id` int(11) DEFAULT NULL,
  `tamano_bytes` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_equipo` (`equipo_id`),
  KEY `fk_foto_usuario` (`subido_por_id`),
  CONSTRAINT `fk_foto_equipo` FOREIGN KEY (`equipo_id`) REFERENCES `equipos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_foto_usuario` FOREIGN KEY (`subido_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipo_fotos`
--

LOCK TABLES `equipo_fotos` WRITE;
/*!40000 ALTER TABLE `equipo_fotos` DISABLE KEYS */;
/*!40000 ALTER TABLE `equipo_fotos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipo_transferencias`
--

DROP TABLE IF EXISTS `equipo_transferencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipo_transferencias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `equipo_id` int(11) NOT NULL,
  `sucursal_origen_id` int(11) DEFAULT NULL COMMENT 'Null si era equipo nuevo recien llegado',
  `sucursal_destino_id` int(11) NOT NULL,
  `area_origen_id` int(11) DEFAULT NULL,
  `area_destino_id` int(11) DEFAULT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `fecha_transferencia` date NOT NULL,
  `realizado_por_id` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_equipo` (`equipo_id`),
  KEY `idx_fecha` (`fecha_transferencia`),
  KEY `fk_trans_origen` (`sucursal_origen_id`),
  KEY `fk_trans_destino` (`sucursal_destino_id`),
  KEY `fk_trans_area_origen` (`area_origen_id`),
  KEY `fk_trans_area_destino` (`area_destino_id`),
  KEY `fk_trans_usuario` (`realizado_por_id`),
  CONSTRAINT `fk_trans_area_destino` FOREIGN KEY (`area_destino_id`) REFERENCES `areas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_trans_area_origen` FOREIGN KEY (`area_origen_id`) REFERENCES `areas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_trans_destino` FOREIGN KEY (`sucursal_destino_id`) REFERENCES `sucursales` (`id`),
  CONSTRAINT `fk_trans_equipo` FOREIGN KEY (`equipo_id`) REFERENCES `equipos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_trans_origen` FOREIGN KEY (`sucursal_origen_id`) REFERENCES `sucursales` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_trans_usuario` FOREIGN KEY (`realizado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipo_transferencias`
--

LOCK TABLES `equipo_transferencias` WRITE;
/*!40000 ALTER TABLE `equipo_transferencias` DISABLE KEYS */;
/*!40000 ALTER TABLE `equipo_transferencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipos`
--

DROP TABLE IF EXISTS `equipos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo_inventario` varchar(50) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `tipo` varchar(50) DEFAULT NULL,
  `marca` varchar(100) DEFAULT NULL,
  `modelo` varchar(100) DEFAULT NULL,
  `numero_serie` varchar(100) DEFAULT NULL,
  `sucursal_id` int(11) NOT NULL,
  `planta_id` int(11) DEFAULT NULL,
  `area_id` int(11) DEFAULT NULL,
  `proveedor_id` int(11) DEFAULT NULL,
  `fecha_compra` date DEFAULT NULL,
  `costo_compra` decimal(12,2) DEFAULT NULL,
  `vida_util_meses` int(11) DEFAULT NULL COMMENT 'Vida util estimada en meses (60 = 5 años)',
  `fecha_baja` date DEFAULT NULL,
  `motivo_baja` varchar(255) DEFAULT NULL,
  `ubicacion` varchar(255) DEFAULT NULL,
  `responsable_id` int(11) DEFAULT NULL,
  `fecha_adquisicion` date DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `estado_vida` enum('nuevo','en_uso','en_reparacion','dado_de_baja') NOT NULL DEFAULT 'en_uso',
  `creado_en` datetime DEFAULT current_timestamp(),
  `actualizado_en` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `pos_x` decimal(5,2) DEFAULT NULL COMMENT '% desde el borde izquierdo',
  `pos_y` decimal(5,2) DEFAULT NULL COMMENT '% desde el borde superior',
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo_inventario` (`codigo_inventario`),
  KEY `area_id` (`area_id`),
  KEY `responsable_id` (`responsable_id`),
  KEY `idx_sucursal_area` (`sucursal_id`,`area_id`),
  KEY `idx_tipo` (`tipo`),
  KEY `fk_equipo_proveedor` (`proveedor_id`),
  KEY `idx_pos` (`pos_x`,`pos_y`),
  KEY `fk_equipo_planta` (`planta_id`),
  CONSTRAINT `equipos_ibfk_1` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursales` (`id`),
  CONSTRAINT `equipos_ibfk_2` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `equipos_ibfk_3` FOREIGN KEY (`responsable_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_equipo_planta` FOREIGN KEY (`planta_id`) REFERENCES `sucursal_plantas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_equipo_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipos`
--

LOCK TABLES `equipos` WRITE;
/*!40000 ALTER TABLE `equipos` DISABLE KEYS */;
INSERT INTO `equipos` VALUES (1,'BAC-001','Teléfono IP BAC-01','Teléfono IP','Brother','Modelo 2018',NULL,1,NULL,11,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 3',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(2,'BAC-002','Router BAC-02','Router','Dell','Modelo 2021',NULL,1,NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 2',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(3,'BAC-003','Impresora BAC-03','Impresora','Cisco','Modelo 2021',NULL,1,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 3',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(4,'BAC-004','Teléfono IP BAC-04','Teléfono IP','Brother','Modelo 2018',NULL,1,NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 4',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(5,'BAC-005','Teléfono IP BAC-05','Teléfono IP','Yealink','Modelo 2018',NULL,1,NULL,11,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 4',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(6,'BAC-006','Cámara IP BAC-06','Cámara IP','Dell','Modelo 2024',NULL,1,1,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 3',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-25 10:13:48',65.58,2.68),(7,'BAC-007','Impresora BAC-07','Impresora','HP','Modelo 2023',NULL,1,NULL,11,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 4',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(8,'BAC-008','Router BAC-08','Router','Lenovo','Modelo 2019',NULL,1,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 1',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(9,'BAC-009','Laptop BAC-09','Laptop','Brother','Modelo 2018',NULL,1,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 5',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(10,'BAC-010','PC BAC-10','PC','Yealink','Modelo 2019',NULL,1,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 5',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(11,'BAC-011','Teléfono IP BAC-11','Teléfono IP','Epson','Modelo 2020',NULL,1,NULL,15,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 1',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(12,'BAC-012','Switch BAC-12','Switch','Lenovo','Modelo 2021',NULL,1,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal BAC · Área 2',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(13,'FER-001','Teléfono IP FER-01','Teléfono IP','Dell','Modelo 2019',NULL,2,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 3',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(14,'FER-002','Laptop FER-02','Laptop','Lenovo','Modelo 2022',NULL,2,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 5',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(15,'FER-003','Punto de Venta FER-03','Punto de Venta','Epson','Modelo 2020',NULL,2,NULL,15,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 2',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(16,'FER-004','Laptop FER-04','Laptop','Cisco','Modelo 2018',NULL,2,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 5',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(17,'FER-005','Cámara IP FER-05','Cámara IP','Cisco','Modelo 2023',NULL,2,NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 5',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(18,'FER-006','Teléfono IP FER-06','Teléfono IP','Lenovo','Modelo 2020',NULL,2,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 5',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(19,'FER-007','Switch FER-07','Switch','Yealink','Modelo 2024',NULL,2,NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 1',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(20,'FER-008','Punto de Venta FER-08','Punto de Venta','Brother','Modelo 2021',NULL,2,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 5',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(21,'FER-009','Cámara IP FER-09','Cámara IP','Dell','Modelo 2021',NULL,2,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 4',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(22,'FER-010','Punto de Venta FER-10','Punto de Venta','HP','Modelo 2024',NULL,2,NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 2',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(23,'FER-011','Cámara IP FER-11','Cámara IP','TP-Link','Modelo 2024',NULL,2,NULL,11,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 2',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL),(24,'FER-012','Teléfono IP FER-12','Teléfono IP','Cisco','Modelo 2019',NULL,2,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,'Sucursal FER · Área 4',NULL,NULL,NULL,1,'en_uso','2026-05-20 17:42:52','2026-05-20 17:42:52',NULL,NULL);
/*!40000 ALTER TABLE `equipos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estados`
--

DROP TABLE IF EXISTS `estados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `orden` int(11) NOT NULL,
  `color` varchar(20) NOT NULL DEFAULT '#6B7280',
  `es_inicial` tinyint(1) NOT NULL DEFAULT 0,
  `es_final` tinyint(1) NOT NULL DEFAULT 0,
  `descripcion` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estados`
--

LOCK TABLES `estados` WRITE;
/*!40000 ALTER TABLE `estados` DISABLE KEYS */;
INSERT INTO `estados` VALUES (1,'Abierta',1,'#DC2626',1,0,'Recién registrada, sin atender',1),(2,'Asignada',2,'#EA580C',0,0,'Asignada a un técnico',1),(3,'En proceso',3,'#D97706',0,0,'Siendo atendida activamente',1),(4,'En espera',4,'#6B7280',0,0,'Esperando información, partes o terceros',1),(5,'Resuelta',5,'#0EA5E9',0,0,'Solucionada, pendiente de confirmación',1),(6,'Completada',6,'#16A34A',0,1,'Confirmada y cerrada',1),(7,'Cancelada',7,'#6B7280',0,1,'Anulada sin resolución',1);
/*!40000 ALTER TABLE `estados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `importaciones`
--

DROP TABLE IF EXISTS `importaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `importaciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` enum('usuarios','equipos','incidencias') NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `total_filas` int(11) NOT NULL DEFAULT 0,
  `exitosos` int(11) NOT NULL DEFAULT 0,
  `fallidos` int(11) NOT NULL DEFAULT 0,
  `errores_json` text DEFAULT NULL COMMENT 'JSON con detalles de errores por fila',
  `realizado_por_id` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_tipo` (`tipo`),
  KEY `idx_fecha` (`creado_en`),
  KEY `fk_import_usuario` (`realizado_por_id`),
  CONSTRAINT `fk_import_usuario` FOREIGN KEY (`realizado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `importaciones`
--

LOCK TABLES `importaciones` WRITE;
/*!40000 ALTER TABLE `importaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `importaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `incidencias`
--

DROP TABLE IF EXISTS `incidencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `incidencias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `folio` varchar(30) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text NOT NULL,
  `sucursal_id` int(11) NOT NULL,
  `area_id` int(11) NOT NULL,
  `categoria_id` int(11) DEFAULT NULL,
  `subcategoria_id` int(11) DEFAULT NULL,
  `tipo_trabajo_id` int(11) DEFAULT NULL,
  `severidad_id` int(11) NOT NULL,
  `estado_id` int(11) NOT NULL,
  `origen_reporte_id` int(11) DEFAULT NULL,
  `equipo_id` int(11) DEFAULT NULL,
  `reportado_por_id` int(11) NOT NULL,
  `reportante_nombre` varchar(150) DEFAULT NULL,
  `reportante_puesto` varchar(100) DEFAULT NULL,
  `asignado_a_id` int(11) DEFAULT NULL,
  `proveedor_escalado_id` int(11) DEFAULT NULL,
  `resuelto_por_id` int(11) DEFAULT NULL,
  `causa_raiz` text DEFAULT NULL,
  `solucion` text DEFAULT NULL,
  `recomendaciones` text DEFAULT NULL,
  `acciones_preventivas` text DEFAULT NULL,
  `es_reincidencia` tinyint(1) NOT NULL DEFAULT 0,
  `incidencia_padre_id` int(11) DEFAULT NULL,
  `veces_recurrida` int(11) NOT NULL DEFAULT 0,
  `fecha_evento` datetime NOT NULL,
  `fecha_atencion` datetime DEFAULT NULL,
  `fecha_resolucion` datetime DEFAULT NULL,
  `fecha_cierre` datetime DEFAULT NULL,
  `tiempo_respuesta_min` int(11) DEFAULT NULL,
  `tiempo_resolucion_min` int(11) DEFAULT NULL,
  `sla_cumplido` tinyint(1) DEFAULT NULL,
  `fecha_limite_sla` datetime DEFAULT NULL,
  `confirmado_por_reportante` tinyint(1) DEFAULT 0,
  `fecha_confirmacion` datetime DEFAULT NULL,
  `calificacion_servicio` int(11) DEFAULT NULL,
  `comentario_reportante` text DEFAULT NULL,
  `creado_en` datetime DEFAULT current_timestamp(),
  `creado_por_id` int(11) NOT NULL,
  `actualizado_en` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `actualizado_por_id` int(11) DEFAULT NULL,
  `archivada` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 si está archivada (resuelta hace >1 año)',
  `fecha_archivado` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `folio` (`folio`),
  KEY `categoria_id` (`categoria_id`),
  KEY `subcategoria_id` (`subcategoria_id`),
  KEY `tipo_trabajo_id` (`tipo_trabajo_id`),
  KEY `estado_id` (`estado_id`),
  KEY `origen_reporte_id` (`origen_reporte_id`),
  KEY `resuelto_por_id` (`resuelto_por_id`),
  KEY `incidencia_padre_id` (`incidencia_padre_id`),
  KEY `creado_por_id` (`creado_por_id`),
  KEY `actualizado_por_id` (`actualizado_por_id`),
  KEY `idx_folio` (`folio`),
  KEY `idx_sucursal_estado` (`sucursal_id`,`estado_id`),
  KEY `idx_area` (`area_id`),
  KEY `idx_severidad` (`severidad_id`),
  KEY `idx_asignado` (`asignado_a_id`),
  KEY `idx_reportado_por` (`reportado_por_id`),
  KEY `idx_equipo` (`equipo_id`),
  KEY `idx_fecha_evento` (`fecha_evento`),
  KEY `idx_reincidencia` (`es_reincidencia`,`incidencia_padre_id`),
  KEY `idx_busqueda_reincidencia` (`equipo_id`,`categoria_id`,`fecha_evento`),
  KEY `fk_incidencia_proveedor` (`proveedor_escalado_id`),
  KEY `idx_archivada` (`archivada`),
  CONSTRAINT `fk_incidencia_proveedor` FOREIGN KEY (`proveedor_escalado_id`) REFERENCES `proveedores` (`id`) ON DELETE SET NULL,
  CONSTRAINT `incidencias_ibfk_1` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursales` (`id`),
  CONSTRAINT `incidencias_ibfk_10` FOREIGN KEY (`reportado_por_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `incidencias_ibfk_11` FOREIGN KEY (`asignado_a_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `incidencias_ibfk_12` FOREIGN KEY (`resuelto_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `incidencias_ibfk_13` FOREIGN KEY (`incidencia_padre_id`) REFERENCES `incidencias` (`id`) ON DELETE SET NULL,
  CONSTRAINT `incidencias_ibfk_14` FOREIGN KEY (`creado_por_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `incidencias_ibfk_15` FOREIGN KEY (`actualizado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `incidencias_ibfk_2` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`),
  CONSTRAINT `incidencias_ibfk_3` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE SET NULL,
  CONSTRAINT `incidencias_ibfk_4` FOREIGN KEY (`subcategoria_id`) REFERENCES `subcategorias` (`id`) ON DELETE SET NULL,
  CONSTRAINT `incidencias_ibfk_5` FOREIGN KEY (`tipo_trabajo_id`) REFERENCES `tipos_trabajo` (`id`) ON DELETE SET NULL,
  CONSTRAINT `incidencias_ibfk_6` FOREIGN KEY (`severidad_id`) REFERENCES `severidades` (`id`),
  CONSTRAINT `incidencias_ibfk_7` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`id`),
  CONSTRAINT `incidencias_ibfk_8` FOREIGN KEY (`origen_reporte_id`) REFERENCES `origenes_reporte` (`id`) ON DELETE SET NULL,
  CONSTRAINT `incidencias_ibfk_9` FOREIGN KEY (`equipo_id`) REFERENCES `equipos` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `incidencias`
--

LOCK TABLES `incidencias` WRITE;
/*!40000 ALTER TABLE `incidencias` DISABLE KEYS */;
INSERT INTO `incidencias` VALUES (1,'INC-FER-2026-0001','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',2,6,3,NULL,11,1,6,NULL,NULL,7,'Jorge Carnicero',NULL,2,NULL,2,NULL,'Se instaló Office 365, se configuró Outlook con la cuenta corporativa y OneDrive.','Mantener inventario de licencias y agilizar entrega para nuevos ingresos.',NULL,0,NULL,0,'2026-05-07 14:17:00','2026-05-07 14:34:00','2026-05-07 14:57:00','2026-05-07 15:56:24',17,23,1,'2026-05-07 16:17:00',0,NULL,NULL,NULL,'2026-05-07 14:17:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(2,'INC-BAC-2026-0001','Disco duro casi lleno en servidor','Alerta automática indica que el disco del servidor de respaldos está al 95%.',1,15,10,NULL,9,1,6,NULL,NULL,9,'Nadia Guerrero',NULL,2,NULL,2,NULL,'Se eliminaron respaldos antiguos según política de retención y se expandió la partición.','Configurar respaldos en almacenamiento adicional o nube.',NULL,0,NULL,0,'2026-05-07 08:56:00','2026-05-07 09:01:00','2026-05-07 10:02:00','2026-05-07 11:57:04',5,61,1,'2026-05-07 10:56:00',0,NULL,NULL,NULL,'2026-05-07 08:56:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(3,'INC-FER-2026-0002','Báscula sin conexión al sistema','La báscula de carnicería no envía las lecturas de peso al sistema de punto de venta.',2,3,11,NULL,9,4,6,NULL,20,2,'Beatriz Cajera',NULL,2,NULL,2,NULL,'Se reconfiguró el puerto COM y se actualizó el driver. Comunicación restablecida.','Hacer respaldo de la configuración de drivers de básculas.',NULL,0,NULL,0,'2026-05-12 09:09:00','2026-05-12 09:50:00','2026-05-12 18:54:00','2026-05-12 18:58:48',41,544,1,'2026-05-15 09:09:00',0,NULL,NULL,NULL,'2026-05-12 09:09:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(4,'INC-BAC-2026-0002','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',1,17,11,NULL,10,2,6,NULL,7,9,'Ana Contable',NULL,2,NULL,2,NULL,'Se instaló Office 365, se configuró Outlook con la cuenta corporativa y OneDrive.','Mantener inventario de licencias y agilizar entrega para nuevos ingresos.',NULL,0,NULL,0,'2026-04-23 13:27:00','2026-04-23 14:25:00','2026-04-23 20:01:00','2026-04-23 20:09:15',58,336,1,'2026-04-23 21:27:00',0,NULL,NULL,NULL,'2026-04-23 13:27:00',9,'2026-05-24 13:41:25',NULL,1,'2026-05-24 20:41:25'),(5,'INC-BAC-2026-0003','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',1,4,8,NULL,5,3,6,NULL,NULL,7,'Nadia Guerrero',NULL,4,NULL,4,NULL,'Se instaló Office 365, se configuró Outlook con la cuenta corporativa y OneDrive.','Mantener inventario de licencias y agilizar entrega para nuevos ingresos.',NULL,0,NULL,0,'2026-04-30 12:04:00','2026-04-30 12:25:00','2026-04-30 18:51:00','2026-04-30 20:27:47',21,386,1,'2026-05-01 12:04:00',0,NULL,NULL,NULL,'2026-04-30 12:04:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(6,'INC-FER-2026-0003','Solicitud de creación de usuario','Nuevo empleado de contabilidad requiere acceso al sistema ERP y cuenta de correo.',2,17,3,NULL,10,2,6,NULL,17,2,'Nadia Guerrero',NULL,4,NULL,4,NULL,'Se creó la cuenta con los permisos correspondientes y se configuró el correo corporativo.','Implementar flujo formal de altas con RH para que llegue completo el requerimiento.',NULL,0,NULL,0,'2026-05-18 10:42:00','2026-05-18 11:36:00','2026-05-18 17:19:00','2026-05-18 18:59:31',54,343,1,'2026-05-18 18:42:00',0,NULL,NULL,NULL,'2026-05-18 10:42:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(7,'INC-BAC-2026-0004','Cámara CCTV sin señal','La cámara de seguridad del área de carga no transmite video al DVR desde anoche.',1,7,1,NULL,9,3,6,NULL,3,9,'Marcos Almacenista',NULL,3,NULL,3,NULL,'Se sustituyó el cable BNC dañado y se reconfiguró el canal. Imagen restaurada.','Inspección mensual de cableado de cámaras y limpieza de conectores.',NULL,0,NULL,0,'2026-05-01 18:40:00','2026-05-01 19:04:00','2026-05-02 15:16:00','2026-05-02 15:50:42',24,1212,1,'2026-05-02 18:40:00',0,NULL,NULL,NULL,'2026-05-01 18:40:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(8,'INC-FER-2026-0004','Soporte de contraseña de caja','Personal de caja no recuerda su contraseña de acceso al sistema de punto de venta.',2,13,7,NULL,10,4,6,NULL,20,4,'Jorge Carnicero',NULL,4,NULL,4,NULL,'Se brindó apoyo al personal proporcionando una nueva contraseña temporal. Se verificó el acceso exitoso.','Implementar política de cambio de contraseña cada 90 días y entrenar al personal en el uso de gestores.',NULL,0,NULL,0,'2026-05-01 08:29:00','2026-05-01 09:23:00','2026-05-01 10:05:00','2026-05-01 11:29:48',54,42,1,'2026-05-04 08:29:00',0,NULL,NULL,NULL,'2026-05-01 08:29:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(9,'INC-FER-2026-0005','Teléfono IP sin tono','El teléfono IP de recepción no tiene tono de marcado, no se pueden hacer ni recibir llamadas.',2,17,9,NULL,13,3,6,NULL,19,2,'Nadia Guerrero',NULL,3,NULL,3,NULL,'Se reinició el dispositivo y se verificó la configuración SIP. Servicio restaurado.','Documentar configuración SIP de todos los teléfonos para recuperación rápida.',NULL,0,NULL,0,'2026-05-05 11:56:00','2026-05-05 12:42:00','2026-05-06 01:08:00','2026-05-06 02:09:30',46,746,1,'2026-05-06 11:56:00',0,NULL,NULL,NULL,'2026-05-05 11:56:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(10,'INC-BAC-2026-0005','Falla en impresora de tickets','La impresora de tickets de la caja 2 no imprime, muestra error de papel aunque sí tiene rollo.',1,7,10,NULL,10,4,6,NULL,3,7,'Beatriz Cajera',NULL,4,NULL,4,NULL,'Se realizó limpieza del cabezal, recalibración y cambio de rodillo. Funciona correctamente.','Programar mantenimiento preventivo trimestral de impresoras de tickets.',NULL,0,NULL,0,'2026-04-28 18:12:00','2026-04-28 18:34:00','2026-05-01 18:10:00','2026-05-01 18:43:01',22,4296,1,'2026-05-01 18:12:00',0,NULL,NULL,NULL,'2026-04-28 18:12:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(11,'INC-BAC-2026-0006','Báscula sin conexión al sistema','La báscula de carnicería no envía las lecturas de peso al sistema de punto de venta.',1,4,11,NULL,12,4,6,NULL,NULL,8,'Beatriz Cajera',NULL,4,NULL,4,NULL,'Se reconfiguró el puerto COM y se actualizó el driver. Comunicación restablecida.','Hacer respaldo de la configuración de drivers de básculas.',NULL,0,NULL,0,'2026-05-02 12:36:00','2026-05-02 13:20:00','2026-05-04 12:55:00','2026-05-04 13:12:28',44,2855,1,'2026-05-05 12:36:00',0,NULL,NULL,NULL,'2026-05-02 12:36:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(12,'INC-BAC-2026-0007','Cuenta de usuario bloqueada','Usuario reporta que no puede acceder al sistema, mensaje de cuenta bloqueada.',1,18,9,NULL,9,4,6,NULL,11,7,'Jorge Carnicero',NULL,3,NULL,3,NULL,'Se desbloqueó la cuenta y se reseteó la contraseña. Acceso restaurado.','Recordar al personal evitar múltiples intentos fallidos.',NULL,0,NULL,0,'2026-05-19 10:06:00','2026-05-19 10:15:00','2026-05-21 06:17:00','2026-05-21 07:44:03',9,2642,1,'2026-05-22 10:06:00',0,NULL,NULL,NULL,'2026-05-19 10:06:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(13,'INC-BAC-2026-0008','Solicitud de creación de usuario','Nuevo empleado de contabilidad requiere acceso al sistema ERP y cuenta de correo.',1,18,8,NULL,13,1,6,NULL,5,2,'Beatriz Cajera',NULL,2,NULL,2,NULL,'Se creó la cuenta con los permisos correspondientes y se configuró el correo corporativo.','Implementar flujo formal de altas con RH para que llegue completo el requerimiento.',NULL,0,NULL,0,'2026-04-27 15:42:00','2026-04-27 16:34:00','2026-04-27 17:04:00','2026-04-27 17:38:23',52,30,1,'2026-04-27 17:42:00',0,NULL,NULL,NULL,'2026-04-27 15:42:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(14,'INC-FER-2026-0006','Punto de venta no factura','El sistema de punto de venta en la caja principal no permite generar facturas, error 503.',2,6,1,NULL,7,3,6,NULL,21,8,'Jorge Carnicero',NULL,2,NULL,2,NULL,'Se reinició el servicio de facturación y se actualizó el certificado SAT. Facturación restaurada.','Configurar alertas automáticas para vencimiento de certificados fiscales.',NULL,0,NULL,0,'2026-05-09 07:40:00','2026-05-09 07:45:00','2026-05-09 11:48:00','2026-05-09 12:39:17',5,243,1,'2026-05-10 07:40:00',0,NULL,NULL,NULL,'2026-05-09 07:40:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(15,'INC-BAC-2026-0009','Disco duro casi lleno en servidor','Alerta automática indica que el disco del servidor de respaldos está al 95%.',1,5,9,NULL,9,4,6,NULL,10,3,'Lucía Oficina',NULL,4,NULL,4,NULL,'Se eliminaron respaldos antiguos según política de retención y se expandió la partición.','Configurar respaldos en almacenamiento adicional o nube.',NULL,0,NULL,0,'2026-04-27 19:24:00','2026-04-27 19:38:00','2026-04-28 11:56:00','2026-04-28 12:33:57',14,978,1,'2026-04-30 19:24:00',0,NULL,NULL,NULL,'2026-04-27 19:24:00',3,'2026-05-20 17:42:52',NULL,0,NULL),(16,'INC-FER-2026-0007','Teléfono IP sin tono','El teléfono IP de recepción no tiene tono de marcado, no se pueden hacer ni recibir llamadas.',2,4,5,NULL,10,3,6,NULL,21,4,'Jorge Carnicero',NULL,4,NULL,4,NULL,'Se reinició el dispositivo y se verificó la configuración SIP. Servicio restaurado.','Documentar configuración SIP de todos los teléfonos para recuperación rápida.',NULL,0,NULL,0,'2026-05-07 19:30:00','2026-05-07 20:06:00','2026-05-08 03:10:00','2026-05-08 05:04:27',36,424,1,'2026-05-08 19:30:00',0,NULL,NULL,NULL,'2026-05-07 19:30:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(17,'INC-BAC-2026-0010','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',1,9,5,NULL,8,4,6,NULL,3,2,'Raúl Reparto',NULL,2,NULL,2,NULL,'Se instaló Office 365, se configuró Outlook con la cuenta corporativa y OneDrive.','Mantener inventario de licencias y agilizar entrega para nuevos ingresos.',NULL,0,NULL,0,'2026-05-11 08:16:00','2026-05-11 08:22:00','2026-05-14 05:14:00','2026-05-14 06:51:11',6,4132,1,'2026-05-14 08:16:00',0,NULL,NULL,NULL,'2026-05-11 08:16:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(18,'INC-BAC-2026-0011','PC de contabilidad muy lenta','La computadora de contabilidad se traba constantemente al abrir el sistema.',1,8,12,NULL,11,2,6,NULL,4,7,'Ana Contable',NULL,4,NULL,4,NULL,'Se realizó limpieza de archivos temporales, desfragmentación y actualización del antivirus. Velocidad mejorada.','Considerar aumento de RAM y migración a SSD. Mantenimiento preventivo cada 6 meses.',NULL,0,NULL,0,'2026-04-21 12:35:00','2026-04-21 13:28:00','2026-04-21 22:30:00','2026-04-22 00:18:59',53,542,0,'2026-04-21 20:35:00',0,NULL,NULL,NULL,'2026-04-21 12:35:00',7,'2026-05-24 13:41:25',NULL,1,'2026-05-24 20:41:25'),(19,'INC-FER-2026-0008','Punto de venta no factura','El sistema de punto de venta en la caja principal no permite generar facturas, error 503.',2,9,9,NULL,6,1,6,NULL,NULL,8,'Nadia Guerrero',NULL,4,NULL,4,NULL,'Se reinició el servicio de facturación y se actualizó el certificado SAT. Facturación restaurada.','Configurar alertas automáticas para vencimiento de certificados fiscales.',NULL,0,NULL,0,'2026-04-30 07:34:00','2026-04-30 07:54:00','2026-04-30 10:18:00','2026-04-30 10:19:10',20,144,0,'2026-04-30 09:34:00',0,NULL,NULL,NULL,'2026-04-30 07:34:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(20,'INC-FER-2026-0009','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',2,14,1,NULL,1,1,6,NULL,24,2,'Beatriz Cajera',NULL,2,NULL,NULL,NULL,'Se instaló Office 365, se configuró Outlook con la cuenta corporativa y OneDrive.','Mantener inventario de licencias y agilizar entrega para nuevos ingresos.',NULL,0,NULL,0,'2026-05-17 16:52:00','2026-05-21 08:58:46','1969-12-31 17:10:00','1969-12-31 17:10:11',5287,0,1,'2026-05-17 18:52:00',0,NULL,NULL,NULL,'2026-05-17 16:52:00',2,'2026-05-24 13:41:25',2,1,'2026-05-24 20:41:25'),(21,'INC-FER-2026-0010','Solicitud de creación de usuario','Nuevo empleado de contabilidad requiere acceso al sistema ERP y cuenta de correo.',2,18,8,NULL,13,4,3,NULL,NULL,9,'Raúl Reparto',NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-04 13:34:00','2026-05-04 14:26:00',NULL,NULL,52,NULL,NULL,'2026-05-07 13:34:00',0,NULL,NULL,NULL,'2026-05-04 13:34:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(22,'INC-BAC-2026-0012','Solicitud de creación de usuario','Nuevo empleado de contabilidad requiere acceso al sistema ERP y cuenta de correo.',1,7,7,NULL,12,3,6,NULL,2,7,'Nadia Guerrero',NULL,4,NULL,4,NULL,'Se creó la cuenta con los permisos correspondientes y se configuró el correo corporativo.','Implementar flujo formal de altas con RH para que llegue completo el requerimiento.',NULL,0,NULL,0,'2026-05-16 12:30:00','2026-05-16 12:52:00','2026-05-17 01:09:00','2026-05-17 02:18:46',22,737,1,'2026-05-17 12:30:00',0,NULL,NULL,NULL,'2026-05-16 12:30:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(23,'INC-FER-2026-0011','Teléfono IP sin tono','El teléfono IP de recepción no tiene tono de marcado, no se pueden hacer ni recibir llamadas.',2,10,11,NULL,12,2,6,NULL,19,4,'Marcos Almacenista',NULL,4,NULL,4,NULL,'Se reinició el dispositivo y se verificó la configuración SIP. Servicio restaurado.','Documentar configuración SIP de todos los teléfonos para recuperación rápida.',NULL,0,NULL,0,'2026-05-13 12:19:00','2026-05-13 12:24:00','2026-05-13 19:42:00','2026-05-13 19:44:01',5,438,1,'2026-05-13 20:19:00',0,NULL,NULL,NULL,'2026-05-13 12:19:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(24,'INC-BAC-2026-0013','Disco duro casi lleno en servidor','Alerta automática indica que el disco del servidor de respaldos está al 95%.',1,18,9,NULL,3,2,6,NULL,9,7,'Jorge Carnicero',NULL,3,NULL,3,NULL,'Se eliminaron respaldos antiguos según política de retención y se expandió la partición.','Configurar respaldos en almacenamiento adicional o nube.',NULL,0,NULL,0,'2026-04-22 16:23:00','2026-04-22 16:33:00','2026-04-22 19:47:00','2026-04-22 20:16:47',10,194,1,'2026-04-23 00:23:00',0,NULL,NULL,NULL,'2026-04-22 16:23:00',7,'2026-05-24 13:41:25',NULL,1,'2026-05-24 20:41:25'),(25,'INC-BAC-2026-0014','Sin acceso a internet en oficinas','No hay acceso a internet en el área administrativa, todos los equipos sin conexión.',1,15,8,NULL,9,2,6,NULL,6,2,'Raúl Reparto',NULL,2,NULL,2,NULL,'Se identificó problema en el switch principal. Se reinició y se reemplazó el cable patch dañado.','Revisar redundancia del switch principal y considerar respaldo de internet.',NULL,0,NULL,0,'2026-05-14 19:26:00','2026-05-14 19:31:00','2026-05-14 21:36:00','2026-05-14 21:56:24',5,125,1,'2026-05-15 03:26:00',0,NULL,NULL,NULL,'2026-05-14 19:26:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(26,'INC-BAC-2026-0015','Disco duro casi lleno en servidor','Alerta automática indica que el disco del servidor de respaldos está al 95%.',1,12,1,NULL,13,3,6,NULL,8,2,'Nadia Guerrero',NULL,4,NULL,4,NULL,'Se eliminaron respaldos antiguos según política de retención y se expandió la partición.','Configurar respaldos en almacenamiento adicional o nube.',NULL,0,NULL,0,'2026-04-23 09:38:00','2026-04-23 09:51:00','2026-04-23 20:19:00','2026-04-23 21:02:31',13,628,1,'2026-04-24 09:38:00',0,NULL,NULL,NULL,'2026-04-23 09:38:00',2,'2026-05-24 13:41:25',NULL,1,'2026-05-24 20:41:25'),(27,'INC-FER-2026-0012','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',2,3,9,NULL,8,4,2,NULL,23,3,'Ana Contable',NULL,4,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-19 07:28:00','2026-05-19 07:58:00',NULL,NULL,30,NULL,NULL,'2026-05-22 07:28:00',0,NULL,NULL,NULL,'2026-05-19 07:28:00',3,'2026-05-20 17:42:52',NULL,0,NULL),(28,'INC-BAC-2026-0016','Sin acceso a internet en oficinas','No hay acceso a internet en el área administrativa, todos los equipos sin conexión.',1,14,7,NULL,14,3,6,NULL,1,8,'Jorge Carnicero',NULL,2,NULL,2,NULL,'Se identificó problema en el switch principal. Se reinició y se reemplazó el cable patch dañado.','Revisar redundancia del switch principal y considerar respaldo de internet.',NULL,0,NULL,0,'2026-05-15 07:08:00','2026-05-15 07:18:00','2026-05-15 21:48:00','2026-05-15 22:41:28',10,870,1,'2026-05-16 07:08:00',0,NULL,NULL,NULL,'2026-05-15 07:08:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(29,'INC-FER-2026-0013','Falla en impresora de tickets','La impresora de tickets de la caja 2 no imprime, muestra error de papel aunque sí tiene rollo.',2,17,7,NULL,2,3,6,NULL,13,3,'Raúl Reparto',NULL,2,NULL,2,NULL,'Se realizó limpieza del cabezal, recalibración y cambio de rodillo. Funciona correctamente.','Programar mantenimiento preventivo trimestral de impresoras de tickets.',NULL,0,NULL,0,'2026-05-15 17:45:00','2026-05-15 18:12:00','2026-05-16 05:22:00','2026-05-16 06:04:00',27,670,1,'2026-05-16 17:45:00',0,NULL,NULL,NULL,'2026-05-15 17:45:00',3,'2026-05-20 17:42:52',NULL,0,NULL),(30,'INC-BAC-2026-0017','Solicitud de creación de usuario','Nuevo empleado de contabilidad requiere acceso al sistema ERP y cuenta de correo.',1,10,7,NULL,12,3,6,NULL,11,8,'Ana Contable',NULL,NULL,NULL,NULL,NULL,'Se creó la cuenta con los permisos correspondientes y se configuró el correo corporativo.','Implementar flujo formal de altas con RH para que llegue completo el requerimiento.',NULL,0,NULL,0,'2026-05-05 07:10:00',NULL,'1969-12-31 23:54:00','1970-01-01 01:01:41',41,474,1,'2026-05-06 07:10:00',0,NULL,NULL,NULL,'2026-05-05 07:10:00',8,'2026-05-24 13:41:25',NULL,1,'2026-05-24 20:41:25'),(31,'INC-BAC-2026-0018','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',1,10,1,NULL,4,3,6,NULL,NULL,2,'Marcos Almacenista',NULL,3,NULL,3,NULL,'Se instaló Office 365, se configuró Outlook con la cuenta corporativa y OneDrive.','Mantener inventario de licencias y agilizar entrega para nuevos ingresos.',NULL,0,NULL,0,'2026-05-19 16:01:00','2026-05-19 16:50:00','2026-05-20 04:35:00','2026-05-20 05:12:07',49,705,1,'2026-05-20 16:01:00',0,NULL,NULL,NULL,'2026-05-19 16:01:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(32,'INC-BAC-2026-0019','Soporte de contraseña de caja','Personal de caja no recuerda su contraseña de acceso al sistema de punto de venta.',1,18,2,NULL,2,4,6,NULL,2,9,'Nadia Guerrero',NULL,3,NULL,3,NULL,'Se brindó apoyo al personal proporcionando una nueva contraseña temporal. Se verificó el acceso exitoso.','Implementar política de cambio de contraseña cada 90 días y entrenar al personal en el uso de gestores.',NULL,0,NULL,0,'2026-05-05 15:34:00','2026-05-05 16:01:00','2026-05-07 13:33:00','2026-05-07 13:44:17',27,2732,1,'2026-05-08 15:34:00',0,NULL,NULL,NULL,'2026-05-05 15:34:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(33,'INC-FER-2026-0014','Báscula sin conexión al sistema','La báscula de carnicería no envía las lecturas de peso al sistema de punto de venta.',2,14,10,NULL,7,3,6,NULL,14,4,'Lucía Oficina',NULL,2,NULL,NULL,NULL,'Se reconfiguró el puerto COM y se actualizó el driver. Comunicación restablecida.','Hacer respaldo de la configuración de drivers de básculas.',NULL,0,NULL,0,'2026-05-20 10:53:00','2026-05-21 08:58:21','1970-01-01 08:16:00','1970-01-01 09:29:56',1325,0,1,'2026-05-21 10:53:00',0,NULL,NULL,NULL,'2026-05-20 10:53:00',4,'2026-05-24 13:41:25',1,1,'2026-05-24 20:41:25'),(34,'INC-BAC-2026-0020','Sin acceso a internet en oficinas','No hay acceso a internet en el área administrativa, todos los equipos sin conexión.',1,7,11,NULL,10,4,6,NULL,10,2,'Jorge Carnicero',NULL,4,NULL,4,NULL,'Se identificó problema en el switch principal. Se reinició y se reemplazó el cable patch dañado.','Revisar redundancia del switch principal y considerar respaldo de internet.',NULL,0,NULL,0,'2026-05-05 10:19:00','2026-05-05 11:16:00','2026-05-07 12:55:00','2026-05-07 13:35:08',57,2979,1,'2026-05-08 10:19:00',0,NULL,NULL,NULL,'2026-05-05 10:19:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(35,'INC-FER-2026-0015','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',2,9,4,NULL,3,4,6,NULL,23,8,'Jorge Carnicero',NULL,3,NULL,3,NULL,'Se instaló Office 365, se configuró Outlook con la cuenta corporativa y OneDrive.','Mantener inventario de licencias y agilizar entrega para nuevos ingresos.',NULL,0,NULL,0,'2026-04-27 12:25:00','2026-04-27 13:25:00','2026-04-27 15:57:00','2026-04-27 15:57:27',60,152,1,'2026-04-30 12:25:00',0,NULL,NULL,NULL,'2026-04-27 12:25:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(36,'INC-BAC-2026-0021','Disco duro casi lleno en servidor','Alerta automática indica que el disco del servidor de respaldos está al 95%.',1,13,7,NULL,1,2,6,NULL,2,3,'Ana Contable',NULL,3,NULL,3,NULL,'Se eliminaron respaldos antiguos según política de retención y se expandió la partición.','Configurar respaldos en almacenamiento adicional o nube.',NULL,0,NULL,0,'2026-05-01 09:19:00','2026-05-01 10:13:00','2026-05-01 11:29:00','2026-05-01 12:12:56',54,76,1,'2026-05-01 17:19:00',0,NULL,NULL,NULL,'2026-05-01 09:19:00',3,'2026-05-20 17:42:52',NULL,0,NULL),(37,'INC-FER-2026-0016','Punto de venta no factura','El sistema de punto de venta en la caja principal no permite generar facturas, error 503.',2,18,7,NULL,8,3,6,NULL,NULL,9,'Marcos Almacenista',NULL,4,NULL,4,NULL,'Se reinició el servicio de facturación y se actualizó el certificado SAT. Facturación restaurada.','Configurar alertas automáticas para vencimiento de certificados fiscales.',NULL,0,NULL,0,'2026-05-14 14:24:00','2026-05-14 14:59:00','2026-05-14 18:37:00','2026-05-14 20:17:05',35,218,1,'2026-05-15 14:24:00',0,NULL,NULL,NULL,'2026-05-14 14:24:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(38,'INC-FER-2026-0017','Alarma activándose sola','La alarma contra incendios se activa sin causa aparente varias veces al día.',2,18,11,NULL,5,4,6,NULL,NULL,3,'Nadia Guerrero',NULL,2,NULL,2,NULL,'Se identificó polvo en el sensor de humo del área de cocina. Se limpiaron todos los sensores.','Programar limpieza trimestral de sensores y revisión anual del sistema de alarma.',NULL,0,NULL,0,'2026-05-04 15:14:00','2026-05-04 16:09:00','2026-05-05 00:24:00','2026-05-05 02:11:49',55,495,1,'2026-05-07 15:14:00',0,NULL,NULL,NULL,'2026-05-04 15:14:00',3,'2026-05-20 17:42:52',NULL,0,NULL),(39,'INC-FER-2026-0018','PC de contabilidad muy lenta','La computadora de contabilidad se traba constantemente al abrir el sistema.',2,2,10,NULL,1,2,6,NULL,15,3,'Raúl Reparto',NULL,2,NULL,2,NULL,'Se realizó limpieza de archivos temporales, desfragmentación y actualización del antivirus. Velocidad mejorada.','Considerar aumento de RAM y migración a SSD. Mantenimiento preventivo cada 6 meses.',NULL,0,NULL,0,'2026-05-15 14:39:00','2026-05-15 15:10:00','2026-05-15 19:31:00','2026-05-15 20:27:19',31,261,1,'2026-05-15 22:39:00',0,NULL,NULL,NULL,'2026-05-15 14:39:00',3,'2026-05-20 17:42:52',NULL,0,NULL),(40,'INC-FER-2026-0019','Lector de código de barras dañado','El lector de barras de la caja 3 ya no lee productos, parece dañado físicamente.',2,5,2,NULL,1,3,2,NULL,23,8,'Sofía Recepción',NULL,4,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-03 07:39:00','2026-05-03 08:25:00',NULL,NULL,46,NULL,NULL,'2026-05-04 07:39:00',0,NULL,NULL,NULL,'2026-05-03 07:39:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(41,'INC-FER-2026-0020','Sin acceso a internet en oficinas','No hay acceso a internet en el área administrativa, todos los equipos sin conexión.',2,16,9,NULL,3,4,1,NULL,22,2,'Raúl Reparto',NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-18 13:21:00','2026-05-18 13:59:00',NULL,NULL,38,NULL,NULL,'2026-05-21 13:21:00',0,NULL,NULL,NULL,'2026-05-18 13:21:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(42,'INC-BAC-2026-0022','Teléfono IP sin tono','El teléfono IP de recepción no tiene tono de marcado, no se pueden hacer ni recibir llamadas.',1,12,1,NULL,2,2,6,NULL,4,4,'Lucía Oficina',NULL,2,NULL,2,NULL,'Se reinició el dispositivo y se verificó la configuración SIP. Servicio restaurado.','Documentar configuración SIP de todos los teléfonos para recuperación rápida.',NULL,0,NULL,0,'2026-05-15 18:03:00','2026-05-15 18:22:00','2026-05-15 19:30:00','2026-05-15 21:25:36',19,68,1,'2026-05-16 02:03:00',0,NULL,NULL,NULL,'2026-05-15 18:03:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(43,'INC-FER-2026-0021','Lector de código de barras dañado','El lector de barras de la caja 3 ya no lee productos, parece dañado físicamente.',2,17,2,NULL,14,3,6,NULL,22,4,'Raúl Reparto',NULL,2,NULL,2,NULL,'Se reemplazó el lector por uno nuevo del stock. Caja operativa.','Mantener al menos 2 lectores de respaldo en almacén de TI.',NULL,0,NULL,0,'2026-04-28 16:51:00','2026-04-28 16:59:00','2026-04-29 14:22:00','2026-04-29 15:05:25',8,1283,1,'2026-04-29 16:51:00',0,NULL,NULL,NULL,'2026-04-28 16:51:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(44,'INC-BAC-2026-0023','Servidor de archivos sin respuesta','Nadie puede acceder a la carpeta compartida del servidor de archivos.',1,2,5,NULL,7,3,3,NULL,4,7,'Nadia Guerrero',NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-16 11:23:00','2026-05-16 11:57:00',NULL,NULL,34,NULL,NULL,'2026-05-17 11:23:00',0,NULL,NULL,NULL,'2026-05-16 11:23:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(45,'INC-BAC-2026-0024','Teléfono IP sin tono','El teléfono IP de recepción no tiene tono de marcado, no se pueden hacer ni recibir llamadas.',1,9,5,NULL,1,2,4,NULL,6,4,'Sofía Recepción',NULL,4,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-09 07:57:00','2026-05-09 08:13:00',NULL,NULL,16,NULL,NULL,'2026-05-09 15:57:00',0,NULL,NULL,NULL,'2026-05-09 07:57:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(46,'INC-BAC-2026-0025','Falla en impresora de tickets','La impresora de tickets de la caja 2 no imprime, muestra error de papel aunque sí tiene rollo.',1,10,12,NULL,6,4,6,NULL,11,4,'Beatriz Cajera',NULL,4,NULL,4,NULL,'Se realizó limpieza del cabezal, recalibración y cambio de rodillo. Funciona correctamente.','Programar mantenimiento preventivo trimestral de impresoras de tickets.',NULL,0,NULL,0,'2026-05-20 13:46:00','2026-05-20 14:04:00','2026-05-22 08:59:00','2026-05-22 10:44:37',18,2575,1,'2026-05-23 13:46:00',0,NULL,NULL,NULL,'2026-05-20 13:46:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(47,'INC-BAC-2026-0026','Punto de venta no factura','El sistema de punto de venta en la caja principal no permite generar facturas, error 503.',1,10,1,NULL,9,3,6,NULL,11,9,'Sofía Recepción',NULL,4,NULL,4,NULL,'Se reinició el servicio de facturación y se actualizó el certificado SAT. Facturación restaurada.','Configurar alertas automáticas para vencimiento de certificados fiscales.',NULL,0,NULL,0,'2026-05-02 09:30:00','2026-05-02 10:14:00','2026-05-02 11:23:00','2026-05-02 12:15:52',44,69,1,'2026-05-03 09:30:00',0,NULL,NULL,NULL,'2026-05-02 09:30:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(48,'INC-BAC-2026-0027','Teléfono IP sin tono','El teléfono IP de recepción no tiene tono de marcado, no se pueden hacer ni recibir llamadas.',1,1,11,NULL,3,2,6,NULL,4,9,'Lucía Oficina',NULL,3,NULL,3,NULL,'Se reinició el dispositivo y se verificó la configuración SIP. Servicio restaurado.','Documentar configuración SIP de todos los teléfonos para recuperación rápida.',NULL,0,NULL,0,'2026-05-15 08:53:00','2026-05-15 09:32:00','2026-05-15 11:14:00','2026-05-15 12:22:02',39,102,1,'2026-05-15 16:53:00',0,NULL,NULL,NULL,'2026-05-15 08:53:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(49,'INC-FER-2026-0022','Servidor de archivos sin respuesta','Nadie puede acceder a la carpeta compartida del servidor de archivos.',2,8,11,NULL,13,3,6,NULL,23,3,'Ana Contable',NULL,NULL,NULL,NULL,NULL,'Se reinició el servicio SMB y se liberó memoria del servidor. Acceso restaurado.','Programar reinicios automáticos del servidor cada domingo a las 3 AM.',NULL,0,NULL,0,'2026-04-30 07:43:00',NULL,'1969-12-31 19:13:00','1969-12-31 19:20:34',30,193,1,'2026-05-01 07:43:00',0,NULL,NULL,NULL,'2026-04-30 07:43:00',3,'2026-05-24 13:41:25',NULL,1,'2026-05-24 20:41:25'),(50,'INC-BAC-2026-0028','Soporte de contraseña de caja','Personal de caja no recuerda su contraseña de acceso al sistema de punto de venta.',1,2,3,NULL,14,4,5,NULL,NULL,8,'Ana Contable',NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-17 12:13:00','2026-05-17 12:43:00',NULL,NULL,30,NULL,NULL,'2026-05-20 12:13:00',0,NULL,NULL,NULL,'2026-05-17 12:13:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(51,'INC-BAC-2026-0029','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',1,5,2,NULL,14,4,6,NULL,12,2,'Beatriz Cajera',NULL,4,NULL,4,NULL,'Se instaló Office 365, se configuró Outlook con la cuenta corporativa y OneDrive.','Mantener inventario de licencias y agilizar entrega para nuevos ingresos.',NULL,0,NULL,0,'2026-05-11 07:10:00','2026-05-11 07:49:00','2026-05-13 21:29:00','2026-05-13 22:02:58',39,3700,1,'2026-05-14 07:10:00',0,NULL,NULL,NULL,'2026-05-11 07:10:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(52,'INC-BAC-2026-0030','Báscula sin conexión al sistema','La báscula de carnicería no envía las lecturas de peso al sistema de punto de venta.',1,17,1,NULL,11,3,6,NULL,11,4,'Lucía Oficina',NULL,4,NULL,4,NULL,'Se reconfiguró el puerto COM y se actualizó el driver. Comunicación restablecida.','Hacer respaldo de la configuración de drivers de básculas.',NULL,0,NULL,0,'2026-05-06 07:51:00','2026-05-06 08:23:00','2026-05-07 07:36:00','2026-05-07 07:38:01',32,1393,1,'2026-05-07 07:51:00',0,NULL,NULL,NULL,'2026-05-06 07:51:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(53,'INC-FER-2026-0023','Solicitud de creación de usuario','Nuevo empleado de contabilidad requiere acceso al sistema ERP y cuenta de correo.',2,18,2,NULL,8,3,6,NULL,NULL,2,'Jorge Carnicero',NULL,2,NULL,2,NULL,'Se creó la cuenta con los permisos correspondientes y se configuró el correo corporativo.','Implementar flujo formal de altas con RH para que llegue completo el requerimiento.',NULL,0,NULL,0,'2026-05-16 08:43:00','2026-05-16 09:35:00','2026-05-17 06:03:00','2026-05-17 07:44:59',52,1228,1,'2026-05-17 08:43:00',0,NULL,NULL,NULL,'2026-05-16 08:43:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(54,'INC-BAC-2026-0031','Sin acceso a internet en oficinas','No hay acceso a internet en el área administrativa, todos los equipos sin conexión.',1,1,12,NULL,9,1,6,NULL,8,8,'Lucía Oficina',NULL,4,NULL,4,NULL,'Se identificó problema en el switch principal. Se reinició y se reemplazó el cable patch dañado.','Revisar redundancia del switch principal y considerar respaldo de internet.',NULL,0,NULL,0,'2026-05-12 14:08:00','2026-05-12 15:08:00','2026-05-12 16:03:00','2026-05-12 17:56:13',60,55,1,'2026-05-12 16:08:00',0,NULL,NULL,NULL,'2026-05-12 14:08:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(55,'INC-FER-2026-0024','Falla en impresora de tickets','La impresora de tickets de la caja 2 no imprime, muestra error de papel aunque sí tiene rollo.',2,11,5,NULL,11,3,3,NULL,19,9,'Raúl Reparto',NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-04-24 09:07:00','2026-04-24 09:27:00',NULL,NULL,20,NULL,NULL,'2026-04-25 09:07:00',0,NULL,NULL,NULL,'2026-04-24 09:07:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(56,'INC-BAC-2026-0032','Disco duro casi lleno en servidor','Alerta automática indica que el disco del servidor de respaldos está al 95%.',1,2,3,NULL,2,4,2,NULL,NULL,4,'Sofía Recepción',NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-09 12:09:00','2026-05-09 12:19:00',NULL,NULL,10,NULL,NULL,'2026-05-12 12:09:00',0,NULL,NULL,NULL,'2026-05-09 12:09:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(57,'INC-BAC-2026-0033','Sin acceso a internet en oficinas','No hay acceso a internet en el área administrativa, todos los equipos sin conexión.',1,3,7,NULL,1,4,1,NULL,11,8,'Raúl Reparto',NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-08 17:29:00','2026-05-08 18:05:00',NULL,NULL,36,NULL,NULL,'2026-05-11 17:29:00',0,NULL,NULL,NULL,'2026-05-08 17:29:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(58,'INC-BAC-2026-0034','Solicitud de creación de usuario','Nuevo empleado de contabilidad requiere acceso al sistema ERP y cuenta de correo.',1,3,7,NULL,7,2,6,NULL,3,7,'Nadia Guerrero',NULL,NULL,NULL,NULL,NULL,'Se creó la cuenta con los permisos correspondientes y se configuró el correo corporativo.','Implementar flujo formal de altas con RH para que llegue completo el requerimiento.',NULL,0,NULL,0,'2026-04-27 12:31:00',NULL,'1969-12-31 22:30:00','1969-12-31 22:49:28',55,390,1,'2026-04-27 20:31:00',0,NULL,NULL,NULL,'2026-04-27 12:31:00',7,'2026-05-24 13:41:25',NULL,1,'2026-05-24 20:41:25'),(59,'INC-FER-2026-0025','Disco duro casi lleno en servidor','Alerta automática indica que el disco del servidor de respaldos está al 95%.',2,11,3,NULL,1,1,6,NULL,20,8,'Lucía Oficina',NULL,NULL,NULL,NULL,NULL,'Se eliminaron respaldos antiguos según política de retención y se expandió la partición.','Configurar respaldos en almacenamiento adicional o nube.',NULL,0,NULL,0,'2026-04-26 16:47:00',NULL,'1969-12-31 18:18:00','1969-12-31 20:16:44',48,138,1,'2026-04-26 18:47:00',0,NULL,NULL,NULL,'2026-04-26 16:47:00',8,'2026-05-24 13:41:25',NULL,1,'2026-05-24 20:41:25'),(60,'INC-FER-2026-0026','Servidor de archivos sin respuesta','Nadie puede acceder a la carpeta compartida del servidor de archivos.',2,6,1,NULL,14,3,6,NULL,NULL,9,'Lucía Oficina',NULL,2,NULL,2,NULL,'Se reinició el servicio SMB y se liberó memoria del servidor. Acceso restaurado.','Programar reinicios automáticos del servidor cada domingo a las 3 AM.',NULL,0,NULL,0,'2026-05-14 10:13:00','2026-05-14 10:43:00','2026-05-14 12:59:00','2026-05-14 13:45:47',30,136,1,'2026-05-15 10:13:00',0,NULL,NULL,NULL,'2026-05-14 10:13:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(61,'INC-FER-2026-0027','PC de contabilidad muy lenta','La computadora de contabilidad se traba constantemente al abrir el sistema.',2,2,12,NULL,6,4,3,NULL,13,3,'Lucía Oficina',NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-15 09:25:00','2026-05-15 09:42:00',NULL,NULL,17,NULL,NULL,'2026-05-18 09:25:00',0,NULL,NULL,NULL,'2026-05-15 09:25:00',3,'2026-05-20 17:42:52',NULL,0,NULL),(62,'INC-BAC-2026-0035','Soporte de contraseña de caja','Personal de caja no recuerda su contraseña de acceso al sistema de punto de venta.',1,1,8,NULL,11,4,6,NULL,8,7,'Jorge Carnicero',NULL,3,NULL,3,NULL,'Se brindó apoyo al personal proporcionando una nueva contraseña temporal. Se verificó el acceso exitoso.','Implementar política de cambio de contraseña cada 90 días y entrenar al personal en el uso de gestores.',NULL,0,NULL,0,'2026-05-18 18:58:00','2026-05-18 19:21:00','2026-05-18 20:19:00','2026-05-18 22:11:54',23,58,1,'2026-05-21 18:58:00',0,NULL,NULL,NULL,'2026-05-18 18:58:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(63,'INC-FER-2026-0028','Servidor de archivos sin respuesta','Nadie puede acceder a la carpeta compartida del servidor de archivos.',2,5,2,NULL,5,2,3,NULL,15,9,'Ana Contable',NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-05 11:38:00','2026-05-05 12:14:00',NULL,NULL,36,NULL,NULL,'2026-05-05 19:38:00',0,NULL,NULL,NULL,'2026-05-05 11:38:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(64,'INC-BAC-2026-0036','Sin acceso a internet en oficinas','No hay acceso a internet en el área administrativa, todos los equipos sin conexión.',1,12,6,NULL,3,3,6,NULL,12,3,'Raúl Reparto',NULL,4,NULL,4,NULL,'Se identificó problema en el switch principal. Se reinició y se reemplazó el cable patch dañado.','Revisar redundancia del switch principal y considerar respaldo de internet.',NULL,0,NULL,0,'2026-05-10 14:19:00','2026-05-10 14:27:00','2026-05-11 02:34:00','2026-05-11 03:13:42',8,727,1,'2026-05-11 14:19:00',0,NULL,NULL,NULL,'2026-05-10 14:19:00',3,'2026-05-20 17:42:52',NULL,0,NULL),(65,'INC-FER-2026-0029','Falla en impresora de tickets','La impresora de tickets de la caja 2 no imprime, muestra error de papel aunque sí tiene rollo.',2,16,8,NULL,12,2,6,NULL,NULL,9,'Jorge Carnicero',NULL,2,NULL,2,NULL,'Se realizó limpieza del cabezal, recalibración y cambio de rodillo. Funciona correctamente.','Programar mantenimiento preventivo trimestral de impresoras de tickets.',NULL,0,NULL,0,'2026-04-26 12:37:00','2026-04-26 12:42:00','2026-04-26 19:34:00','2026-04-26 19:42:10',5,412,1,'2026-04-26 20:37:00',0,NULL,NULL,NULL,'2026-04-26 12:37:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(66,'INC-FER-2026-0030','Cuenta de usuario bloqueada','Usuario reporta que no puede acceder al sistema, mensaje de cuenta bloqueada.',2,7,1,NULL,11,3,3,NULL,21,9,'Jorge Carnicero',NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-07 09:21:00','2026-05-07 10:02:00',NULL,NULL,41,NULL,NULL,'2026-05-08 09:21:00',0,NULL,NULL,NULL,'2026-05-07 09:21:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(67,'INC-FER-2026-0031','Solicitud de instalación de Office','Nuevo equipo en oficina requiere instalación de paquetería Office y configuración de correo.',2,12,6,NULL,3,2,6,NULL,20,2,'Sofía Recepción',NULL,3,NULL,3,NULL,'Se instaló Office 365, se configuró Outlook con la cuenta corporativa y OneDrive.','Mantener inventario de licencias y agilizar entrega para nuevos ingresos.',NULL,0,NULL,0,'2026-04-27 10:46:00','2026-04-27 11:33:00','2026-04-27 16:34:00','2026-04-27 17:28:04',47,301,1,'2026-04-27 18:46:00',0,NULL,NULL,NULL,'2026-04-27 10:46:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(68,'INC-FER-2026-0032','Cuenta de usuario bloqueada','Usuario reporta que no puede acceder al sistema, mensaje de cuenta bloqueada.',2,2,12,NULL,13,3,6,NULL,22,3,'Jorge Carnicero',NULL,4,NULL,4,NULL,'Se desbloqueó la cuenta y se reseteó la contraseña. Acceso restaurado.','Recordar al personal evitar múltiples intentos fallidos.',NULL,0,NULL,0,'2026-04-28 11:36:00','2026-04-28 11:56:00','2026-04-28 16:02:00','2026-04-28 17:06:14',20,246,1,'2026-04-29 11:36:00',0,NULL,NULL,NULL,'2026-04-28 11:36:00',3,'2026-05-20 17:42:52',NULL,0,NULL),(69,'INC-FER-2026-0033','Servidor de archivos sin respuesta','Nadie puede acceder a la carpeta compartida del servidor de archivos.',2,11,6,NULL,12,3,6,NULL,23,7,'Jorge Carnicero',NULL,4,NULL,4,NULL,'Se reinició el servicio SMB y se liberó memoria del servidor. Acceso restaurado.','Programar reinicios automáticos del servidor cada domingo a las 3 AM.',NULL,0,NULL,0,'2026-05-18 16:52:00','2026-05-18 17:38:00','2026-05-19 06:37:00','2026-05-19 06:58:00',46,779,1,'2026-05-19 16:52:00',0,NULL,NULL,NULL,'2026-05-18 16:52:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(70,'INC-BAC-2026-0037','Falla en impresora de tickets','La impresora de tickets de la caja 2 no imprime, muestra error de papel aunque sí tiene rollo.',1,14,11,NULL,7,4,2,NULL,7,9,'Lucía Oficina',NULL,4,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-08 08:47:00','2026-05-08 09:40:00',NULL,NULL,53,NULL,NULL,'2026-05-11 08:47:00',0,NULL,NULL,NULL,'2026-05-08 08:47:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(71,'INC-BAC-2026-0038','Disco duro casi lleno en servidor','Alerta automática indica que el disco del servidor de respaldos está al 95%.',1,16,8,NULL,13,4,3,NULL,7,8,'Ana Contable',NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-04-24 13:53:00','2026-04-24 14:34:00',NULL,NULL,41,NULL,NULL,'2026-04-27 13:53:00',0,NULL,NULL,NULL,'2026-04-24 13:53:00',8,'2026-05-20 17:42:52',NULL,0,NULL),(72,'INC-FER-2026-0034','Lector de código de barras dañado','El lector de barras de la caja 3 ya no lee productos, parece dañado físicamente.',2,16,11,NULL,12,4,6,NULL,21,9,'Marcos Almacenista',NULL,3,NULL,3,NULL,'Se reemplazó el lector por uno nuevo del stock. Caja operativa.','Mantener al menos 2 lectores de respaldo en almacén de TI.',NULL,0,NULL,0,'2026-05-08 10:34:00','2026-05-08 11:05:00','2026-05-10 04:46:00','2026-05-10 05:06:35',31,2501,1,'2026-05-11 10:34:00',0,NULL,NULL,NULL,'2026-05-08 10:34:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(73,'INC-FER-2026-0035','Servidor de archivos sin respuesta','Nadie puede acceder a la carpeta compartida del servidor de archivos.',2,1,4,NULL,8,4,6,NULL,22,7,'Sofía Recepción',NULL,3,NULL,3,NULL,'Se reinició el servicio SMB y se liberó memoria del servidor. Acceso restaurado.','Programar reinicios automáticos del servidor cada domingo a las 3 AM.',NULL,0,NULL,0,'2026-05-05 08:06:00','2026-05-05 08:41:00','2026-05-05 17:04:00','2026-05-05 18:56:45',35,503,1,'2026-05-08 08:06:00',0,NULL,NULL,NULL,'2026-05-05 08:06:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(74,'INC-BAC-2026-0039','Punto de venta no factura','El sistema de punto de venta en la caja principal no permite generar facturas, error 503.',1,17,2,NULL,14,2,6,NULL,NULL,7,'Raúl Reparto',NULL,4,NULL,4,NULL,'Se reinició el servicio de facturación y se actualizó el certificado SAT. Facturación restaurada.','Configurar alertas automáticas para vencimiento de certificados fiscales.',NULL,0,NULL,0,'2026-05-06 14:34:00','2026-05-06 15:34:00','2026-05-06 16:23:00','2026-05-06 16:49:23',60,49,1,'2026-05-06 22:34:00',0,NULL,NULL,NULL,'2026-05-06 14:34:00',7,'2026-05-20 17:42:52',NULL,0,NULL),(75,'INC-BAC-2026-0040','Sin acceso a internet en oficinas','No hay acceso a internet en el área administrativa, todos los equipos sin conexión.',1,6,4,NULL,9,3,6,NULL,6,9,'Lucía Oficina',NULL,2,NULL,2,NULL,'Se identificó problema en el switch principal. Se reinició y se reemplazó el cable patch dañado.','Revisar redundancia del switch principal y considerar respaldo de internet.',NULL,0,NULL,0,'2026-05-12 13:15:00','2026-05-12 13:48:00','2026-05-12 14:06:00','2026-05-12 14:23:38',33,18,1,'2026-05-13 13:15:00',0,NULL,NULL,NULL,'2026-05-12 13:15:00',9,'2026-05-20 17:42:52',NULL,0,NULL),(76,'INC-BAC-2026-0041','Soporte de contraseña de caja','Personal de caja no recuerda su contraseña de acceso al sistema de punto de venta.',1,9,3,NULL,8,3,3,NULL,6,2,'Lucía Oficina',NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-20 19:44:00','2026-05-20 20:30:00',NULL,NULL,46,NULL,NULL,'2026-05-21 19:44:00',0,NULL,NULL,NULL,'2026-05-20 19:44:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(77,'INC-BAC-2026-0042','Teléfono IP sin tono','El teléfono IP de recepción no tiene tono de marcado, no se pueden hacer ni recibir llamadas.',1,17,11,NULL,3,4,6,NULL,7,9,'Sofía Recepción',NULL,NULL,NULL,NULL,NULL,'Se reinició el dispositivo y se verificó la configuración SIP. Servicio restaurado.','Documentar configuración SIP de todos los teléfonos para recuperación rápida.',NULL,1,4,0,'2026-05-16 07:18:00',NULL,'1970-01-02 21:40:00','1970-01-02 23:18:03',36,3220,1,'2026-05-19 07:18:00',0,NULL,NULL,NULL,'2026-05-16 07:18:00',9,'2026-05-24 13:41:25',NULL,1,'2026-05-24 20:41:25'),(78,'INC-BAC-2026-0043','Punto de venta no factura','El sistema de punto de venta en la caja principal no permite generar facturas, error 503.',1,10,2,NULL,5,4,6,NULL,2,2,'Jorge Carnicero',NULL,2,NULL,2,NULL,'Se reinició el servicio de facturación y se actualizó el certificado SAT. Facturación restaurada.','Configurar alertas automáticas para vencimiento de certificados fiscales.',NULL,0,NULL,0,'2026-05-06 14:46:00','2026-05-06 15:43:00','2026-05-08 03:39:00','2026-05-08 04:03:37',57,2156,1,'2026-05-09 14:46:00',0,NULL,NULL,NULL,'2026-05-06 14:46:00',2,'2026-05-20 17:42:52',NULL,0,NULL),(79,'INC-FER-2026-0036','Báscula sin conexión al sistema','La báscula de carnicería no envía las lecturas de peso al sistema de punto de venta.',2,12,4,NULL,11,4,4,NULL,17,4,'Sofía Recepción',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-04-23 07:19:00',NULL,NULL,NULL,5,NULL,NULL,'2026-04-26 07:19:00',0,NULL,NULL,NULL,'2026-04-23 07:19:00',4,'2026-05-20 17:42:52',NULL,0,NULL),(80,'INC-FER-2026-0037','Alarma activándose sola','La alarma contra incendios se activa sin causa aparente varias veces al día.',2,7,5,NULL,13,1,3,NULL,17,4,'Beatriz Cajera',NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-04-28 13:35:00','2026-05-24 13:24:20',NULL,NULL,37429,NULL,NULL,'2026-04-28 15:35:00',0,NULL,NULL,NULL,'2026-04-28 13:35:00',4,'2026-05-24 13:24:20',1,0,NULL),(81,'INC-BAC-2026-0044','Falla Inicial prueba del sistema','Esta falla es para probar el sistema de incidencias',1,15,12,NULL,11,4,4,1,10,1,'Luis Roodriguez','Jefe de Sistemas',2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,1,'2026-05-21 08:47:00','2026-05-21 08:50:34',NULL,NULL,4,NULL,NULL,'2026-05-24 08:47:00',0,NULL,NULL,NULL,'2026-05-21 08:50:34',1,'2026-05-24 13:24:45',1,0,NULL),(82,'INC-BAC-2026-0045','Falla Inicial prueba del sistema','Esta falla es para probar el sistema de incidencias',1,15,12,NULL,11,4,1,NULL,10,1,NULL,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,1,81,0,'2026-05-21 08:55:00','2026-05-24 13:21:37',NULL,NULL,4587,NULL,NULL,'2026-05-24 08:55:00',0,NULL,NULL,NULL,'2026-05-21 08:55:30',1,'2026-05-24 13:21:37',1,0,NULL),(83,'INC-BAC-2026-0046','Falla secundaria prueba del sistema','Pruaba2',1,15,2,5,1,4,1,1,10,1,'Luis Roodriguez','Jefe de Sistemas',2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-24 08:45:00','2026-05-24 08:47:19',NULL,NULL,2,NULL,NULL,'2026-05-27 08:45:00',0,NULL,NULL,NULL,'2026-05-24 08:47:19',1,'2026-05-24 08:47:19',NULL,0,NULL),(84,'INC-BAC-2026-0047','Falla secundaria prueba del sistema','Falla 2, prueba 2.',1,19,2,5,11,4,1,1,10,10,'Luis Roodriguez','Jefe de Sistemas',2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-24 13:11:00','2026-05-24 13:11:56',NULL,NULL,1,NULL,NULL,'2026-05-27 13:11:00',0,NULL,NULL,NULL,'2026-05-24 13:11:56',10,'2026-05-24 13:11:56',NULL,0,NULL),(85,'INC-BAC-2026-0048','Falla secundaria prueba del sistema','Falla 2, prueba 2.',1,19,2,5,11,4,1,1,10,1,'Luis Roodriguez','Jefe de Sistemas',2,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,'2026-05-24 13:21:00','2026-05-24 13:22:21',NULL,NULL,1,NULL,NULL,'2026-05-27 13:21:00',0,NULL,NULL,NULL,'2026-05-24 13:22:21',1,'2026-05-24 13:22:21',NULL,0,NULL);
/*!40000 ALTER TABLE `incidencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `incidencias_adjuntos`
--

DROP TABLE IF EXISTS `incidencias_adjuntos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `incidencias_adjuntos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `incidencia_id` int(11) NOT NULL,
  `nombre_original` varchar(255) NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `ruta` varchar(500) NOT NULL,
  `tipo_mime` varchar(100) DEFAULT NULL,
  `tamano_bytes` int(11) DEFAULT NULL,
  `momento` varchar(20) DEFAULT 'durante',
  `descripcion` varchar(255) DEFAULT NULL,
  `subido_por_id` int(11) NOT NULL,
  `subido_en` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `subido_por_id` (`subido_por_id`),
  KEY `idx_incidencia` (`incidencia_id`),
  CONSTRAINT `incidencias_adjuntos_ibfk_1` FOREIGN KEY (`incidencia_id`) REFERENCES `incidencias` (`id`) ON DELETE CASCADE,
  CONSTRAINT `incidencias_adjuntos_ibfk_2` FOREIGN KEY (`subido_por_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `incidencias_adjuntos`
--

LOCK TABLES `incidencias_adjuntos` WRITE;
/*!40000 ALTER TABLE `incidencias_adjuntos` DISABLE KEYS */;
INSERT INTO `incidencias_adjuntos` VALUES (1,81,'Captura1.png','7b52430dda9563500c69ea16eb825689.png','uploads/2026/05/7b52430dda9563500c69ea16eb825689.png','image/png',196150,'durante',NULL,1,'2026-05-21 08:50:34');
/*!40000 ALTER TABLE `incidencias_adjuntos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `incidencias_comentarios`
--

DROP TABLE IF EXISTS `incidencias_comentarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `incidencias_comentarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `incidencia_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `comentario` text NOT NULL,
  `es_interno` tinyint(1) NOT NULL DEFAULT 0,
  `creado_en` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `idx_incidencia` (`incidencia_id`),
  CONSTRAINT `incidencias_comentarios_ibfk_1` FOREIGN KEY (`incidencia_id`) REFERENCES `incidencias` (`id`) ON DELETE CASCADE,
  CONSTRAINT `incidencias_comentarios_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `incidencias_comentarios`
--

LOCK TABLES `incidencias_comentarios` WRITE;
/*!40000 ALTER TABLE `incidencias_comentarios` DISABLE KEYS */;
INSERT INTO `incidencias_comentarios` VALUES (1,81,1,'Prueba realizada con exito',0,'2026-05-21 08:54:30'),(2,85,1,'@abraham Prueba de mencion',0,'2026-05-25 08:30:13'),(3,85,1,'@abraham prueba de mencion 2',0,'2026-05-25 08:51:54');
/*!40000 ALTER TABLE `incidencias_comentarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `incidencias_etiquetas`
--

DROP TABLE IF EXISTS `incidencias_etiquetas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `incidencias_etiquetas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `incidencia_id` int(11) NOT NULL,
  `etiqueta` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_incidencia_etiqueta` (`incidencia_id`,`etiqueta`),
  KEY `idx_etiqueta` (`etiqueta`),
  CONSTRAINT `incidencias_etiquetas_ibfk_1` FOREIGN KEY (`incidencia_id`) REFERENCES `incidencias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `incidencias_etiquetas`
--

LOCK TABLES `incidencias_etiquetas` WRITE;
/*!40000 ALTER TABLE `incidencias_etiquetas` DISABLE KEYS */;
/*!40000 ALTER TABLE `incidencias_etiquetas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `incidencias_historial`
--

DROP TABLE IF EXISTS `incidencias_historial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `incidencias_historial` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `incidencia_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `accion` varchar(50) NOT NULL,
  `campo` varchar(100) DEFAULT NULL,
  `valor_anterior` text DEFAULT NULL,
  `valor_nuevo` text DEFAULT NULL,
  `descripcion` varchar(500) DEFAULT NULL,
  `creado_en` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `idx_incidencia` (`incidencia_id`),
  KEY `idx_fecha` (`creado_en`),
  CONSTRAINT `incidencias_historial_ibfk_1` FOREIGN KEY (`incidencia_id`) REFERENCES `incidencias` (`id`) ON DELETE CASCADE,
  CONSTRAINT `incidencias_historial_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `incidencias_historial`
--

LOCK TABLES `incidencias_historial` WRITE;
/*!40000 ALTER TABLE `incidencias_historial` DISABLE KEYS */;
INSERT INTO `incidencias_historial` VALUES (1,81,1,'adjuntos_subidos','adjuntos',NULL,'1 archivo(s)','1 archivo(s) adjuntados al crear','2026-05-21 08:50:34'),(2,81,1,'creada',NULL,NULL,'INC-BAC-2026-0044','Incidencia creada con folio INC-BAC-2026-0044','2026-05-21 08:50:34'),(3,81,1,'asignado','asignado_a_id','2','1','Asignado a Administrador del Sistema','2026-05-21 08:54:04'),(4,81,1,'asignado','asignado_a_id','1','2','Asignado a Abraham García','2026-05-21 08:54:11'),(5,81,1,'estado_cambiado','estado_id','1','4','Estado cambiado a En espera','2026-05-21 08:55:03'),(6,82,1,'creada',NULL,NULL,'INC-BAC-2026-0045','Incidencia creada con folio INC-BAC-2026-0045','2026-05-21 08:55:30'),(7,33,1,'asignado','asignado_a_id','','2','Asignado a Abraham García','2026-05-21 08:58:21'),(8,20,2,'asignado','asignado_a_id','','2','Asignado a Abraham García','2026-05-21 08:58:46'),(11,81,1,'asignado','asignado_a_id','2','','Asignado a sin asignar','2026-05-24 08:44:47'),(14,83,1,'creada',NULL,NULL,'INC-BAC-2026-0046','Incidencia creada con folio INC-BAC-2026-0046','2026-05-24 08:47:19'),(15,84,10,'creada',NULL,NULL,'INC-BAC-2026-0047','Incidencia creada con folio INC-BAC-2026-0047','2026-05-24 13:11:56'),(16,82,1,'asignado','asignado_a_id','','2','Asignado a Abraham García','2026-05-24 13:21:37'),(17,85,1,'creada',NULL,NULL,'INC-BAC-2026-0048','Incidencia creada con folio INC-BAC-2026-0048','2026-05-24 13:22:21'),(18,80,1,'asignado','asignado_a_id','','2','Asignado a Abraham García','2026-05-24 13:24:20'),(19,81,1,'asignado','asignado_a_id','','2','Asignado a Abraham García','2026-05-24 13:24:45'),(20,81,1,'asignado','asignado_a_id','2','2','Asignado a Abraham García','2026-05-24 13:24:45');
/*!40000 ALTER TABLE `incidencias_historial` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mantenimientos`
--

DROP TABLE IF EXISTS `mantenimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mantenimientos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `equipo_id` int(11) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_programada` date NOT NULL,
  `hora_programada` time DEFAULT NULL,
  `asignado_a_id` int(11) DEFAULT NULL COMMENT 'Tecnico asignado',
  `proveedor_id` int(11) DEFAULT NULL COMMENT 'Si lo hace un proveedor externo',
  `estado` enum('programado','proximo','en_progreso','completado','cancelado','vencido') NOT NULL DEFAULT 'programado',
  `es_recurrente` tinyint(1) NOT NULL DEFAULT 0,
  `recurrencia_tipo` enum('dias','semanas','meses','anios') DEFAULT NULL,
  `recurrencia_valor` int(11) DEFAULT NULL COMMENT 'Cada cuantas unidades (ej. 3 meses)',
  `mantenimiento_padre_id` int(11) DEFAULT NULL COMMENT 'Si fue auto-generado, apunta al original',
  `fecha_inicio_real` datetime DEFAULT NULL,
  `fecha_completado` datetime DEFAULT NULL,
  `realizado_por_id` int(11) DEFAULT NULL COMMENT 'Quien lo ejecuto realmente',
  `resultado` text DEFAULT NULL COMMENT 'Notas de lo que se hizo',
  `costo` decimal(10,2) DEFAULT NULL,
  `incidencia_generada_id` int(11) DEFAULT NULL COMMENT 'Si se convirtio en incidencia',
  `creado_por_id` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_equipo` (`equipo_id`),
  KEY `idx_estado` (`estado`),
  KEY `idx_fecha` (`fecha_programada`),
  KEY `idx_asignado` (`asignado_a_id`),
  KEY `idx_padre` (`mantenimiento_padre_id`),
  KEY `fk_mant_proveedor` (`proveedor_id`),
  KEY `fk_mant_realizado` (`realizado_por_id`),
  KEY `fk_mant_creador` (`creado_por_id`),
  KEY `fk_mant_incidencia` (`incidencia_generada_id`),
  CONSTRAINT `fk_mant_asignado` FOREIGN KEY (`asignado_a_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_mant_creador` FOREIGN KEY (`creado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_mant_equipo` FOREIGN KEY (`equipo_id`) REFERENCES `equipos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mant_incidencia` FOREIGN KEY (`incidencia_generada_id`) REFERENCES `incidencias` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_mant_padre` FOREIGN KEY (`mantenimiento_padre_id`) REFERENCES `mantenimientos` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_mant_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_mant_realizado` FOREIGN KEY (`realizado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mantenimientos`
--

LOCK TABLES `mantenimientos` WRITE;
/*!40000 ALTER TABLE `mantenimientos` DISABLE KEYS */;
/*!40000 ALTER TABLE `mantenimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificaciones`
--

DROP TABLE IF EXISTS `notificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `mensaje` text DEFAULT NULL,
  `enlace` varchar(500) DEFAULT NULL,
  `leida` tinyint(1) NOT NULL DEFAULT 0,
  `leida_en` datetime DEFAULT NULL,
  `creada_en` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_usuario_leida` (`usuario_id`,`leida`),
  KEY `idx_fecha` (`creada_en`),
  CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificaciones`
--

LOCK TABLES `notificaciones` WRITE;
/*!40000 ALTER TABLE `notificaciones` DISABLE KEYS */;
INSERT INTO `notificaciones` VALUES (1,2,'asignacion','Se te asignó INC-BAC-2026-0045','Falla Inicial prueba del sistema · Severidad: Baja','/localhost/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=82',0,NULL,'2026-05-24 13:21:37'),(2,2,'asignacion','Se te asignó INC-BAC-2026-0048','Falla secundaria prueba del sistema · Severidad: Baja','/localhost/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=85',0,NULL,'2026-05-24 13:22:21'),(3,2,'asignacion','Se te asignó INC-FER-2026-0037','Alarma activándose sola · Severidad: Crítica','/localhost/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=80',1,'2026-05-25 08:43:03','2026-05-24 13:24:20'),(4,2,'asignacion','Se te asignó INC-BAC-2026-0044','Falla Inicial prueba del sistema · Severidad: Baja','/localhost/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=81',1,'2026-05-25 08:51:16','2026-05-24 13:24:45'),(5,2,'asignacion','Se te asignó INC-BAC-2026-0044','Falla Inicial prueba del sistema · Severidad: Baja','/localhost/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=81',1,'2026-05-25 08:50:28','2026-05-24 13:24:45'),(6,2,'comentario','Nuevo comentario en INC-BAC-2026-0048','Administrador del Sistema: \"@abraham Prueba de mencion\"','/localhost/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=85',1,'2026-05-25 08:51:10','2026-05-25 08:30:13'),(7,2,'mencion','Te mencionaron en INC-BAC-2026-0048','@abraham Prueba de mencion','/localhost/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=85#comentarios',1,'2026-05-25 08:49:54','2026-05-25 08:30:13'),(8,2,'comentario','Nuevo comentario en INC-BAC-2026-0048','Administrador del Sistema: \"@abraham prueba de mencion 2\"','/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=85',1,'2026-05-25 08:52:02','2026-05-25 08:51:54'),(9,2,'mencion','Te mencionaron en INC-BAC-2026-0048','@abraham prueba de mencion 2','/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=85#comentarios',0,NULL,'2026-05-25 08:51:54');
/*!40000 ALTER TABLE `notificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `origenes_reporte`
--

DROP TABLE IF EXISTS `origenes_reporte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `origenes_reporte` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `origenes_reporte`
--

LOCK TABLES `origenes_reporte` WRITE;
/*!40000 ALTER TABLE `origenes_reporte` DISABLE KEYS */;
INSERT INTO `origenes_reporte` VALUES (1,'Presencial',1),(2,'Telefónico',1),(3,'WhatsApp',1),(4,'Correo electrónico',1),(5,'Sistema',1),(6,'Mantenimiento programado',1),(7,'Otro',1);
/*!40000 ALTER TABLE `origenes_reporte` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plantillas_incidencias`
--

DROP TABLE IF EXISTS `plantillas_incidencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plantillas_incidencias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Para mostrar en la lista de plantillas',
  `icono` varchar(50) DEFAULT 'file-text' COMMENT 'Nombre del icono Lucide',
  `color` varchar(7) DEFAULT '#6B7280',
  `titulo` varchar(255) DEFAULT NULL,
  `descripcion_inc` text DEFAULT NULL COMMENT 'Descripcion del problema pre-rellenada',
  `area_id` int(11) DEFAULT NULL,
  `categoria_id` int(11) DEFAULT NULL,
  `subcategoria_id` int(11) DEFAULT NULL,
  `tipo_trabajo_id` int(11) DEFAULT NULL,
  `severidad_id` int(11) DEFAULT NULL,
  `origen_reporte_id` int(11) DEFAULT NULL,
  `solucion_sugerida` text DEFAULT NULL COMMENT 'Solucion tipica para este problema',
  `usos` int(11) NOT NULL DEFAULT 0 COMMENT 'Veces que se ha usado esta plantilla',
  `creado_por_id` int(11) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_activo` (`activo`),
  KEY `idx_usos` (`usos`),
  KEY `fk_plantilla_area` (`area_id`),
  KEY `fk_plantilla_categoria` (`categoria_id`),
  KEY `fk_plantilla_subcategoria` (`subcategoria_id`),
  KEY `fk_plantilla_tipo` (`tipo_trabajo_id`),
  KEY `fk_plantilla_severidad` (`severidad_id`),
  KEY `fk_plantilla_origen` (`origen_reporte_id`),
  KEY `fk_plantilla_creador` (`creado_por_id`),
  CONSTRAINT `fk_plantilla_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_plantilla_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_plantilla_creador` FOREIGN KEY (`creado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_plantilla_origen` FOREIGN KEY (`origen_reporte_id`) REFERENCES `origenes_reporte` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_plantilla_severidad` FOREIGN KEY (`severidad_id`) REFERENCES `severidades` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_plantilla_subcategoria` FOREIGN KEY (`subcategoria_id`) REFERENCES `subcategorias` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_plantilla_tipo` FOREIGN KEY (`tipo_trabajo_id`) REFERENCES `tipos_trabajo` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plantillas_incidencias`
--

LOCK TABLES `plantillas_incidencias` WRITE;
/*!40000 ALTER TABLE `plantillas_incidencias` DISABLE KEYS */;
INSERT INTO `plantillas_incidencias` VALUES (1,'Reset de contraseña','Usuario olvido su contraseña del sistema','key','#D97706','Solicitud de reseteo de contraseña','El usuario no puede acceder al sistema y solicita el reseteo de su contraseña.\n\nUsuario: \nMotivo: ',2,10,NULL,9,4,2,'1. Verificar identidad del usuario\n2. Resetear contraseña desde el panel admin\n3. Comunicar nueva contraseña temporal de forma segura\n4. Confirmar que el usuario pudo acceder y cambiar la contraseña',0,NULL,1,'2026-05-22 02:03:16','2026-05-22 02:03:16'),(2,'Impresora sin tinta/toner','Falta consumible en impresora','printer','#7C3AED','Impresora sin tinta/toner','La impresora no imprime por falta de consumible.\n\nUbicacion: \nModelo: \nTipo de consumible necesario: ',NULL,1,NULL,8,2,1,'1. Confirmar modelo exacto de impresora\n2. Verificar inventario de consumibles\n3. Reemplazar tinta/toner\n4. Imprimir pagina de prueba para validar',0,NULL,1,'2026-05-22 02:03:16','2026-05-22 02:03:16'),(3,'Internet caido / lento','Perdida de conectividad o lentitud','wifi-off','#DC2626','Sin conexion a internet','Se reporta perdida total/parcial de conexion a internet.\n\nAreas afectadas: \nDispositivos afectados: \nHora aproximada del incidente: ',NULL,3,NULL,9,2,2,'1. Verificar luces del modem/router\n2. Reiniciar equipos de red (apagar 30 segundos)\n3. Verificar cableado fisico\n4. Contactar al proveedor si persiste\n5. Documentar tiempo de inactividad',0,NULL,1,'2026-05-22 02:03:16','2026-05-22 02:03:16'),(4,'Falla en terminal POS','Terminal/caja registradora no funciona','monitor-x','#DC2626','Falla en terminal de punto de venta','La terminal de punto de venta presenta fallas.\n\nCaja: \nSintoma especifico: \nUltima operacion exitosa: ',1,6,NULL,9,1,2,'1. Verificar conexiones fisicas\n2. Reiniciar la terminal\n3. Validar conexion con servidor central\n4. Si persiste, habilitar caja de respaldo y escalar',0,NULL,1,'2026-05-22 02:03:16','2026-05-22 02:03:16'),(5,'Bascula descalibrada','Bascula marca peso incorrecto','scale','#EA580C','Bascula descalibrada o con error de pesaje','La bascula presenta lecturas incorrectas o erraticas.\n\nUbicacion: \nModelo: \nMargen de error observado: ',NULL,1,NULL,8,2,1,'1. Limpiar el plato y sensor\n2. Verificar nivelacion de la bascula\n3. Calibrar con pesa patron\n4. Si no calibra, agendar servicio tecnico especializado',0,NULL,1,'2026-05-22 02:03:16','2026-05-22 02:03:16'),(6,'PC lenta o con problemas','Equipo de computo con bajo rendimiento','cpu','#0EA5E9','Computadora con rendimiento lento','La PC presenta lentitud para realizar tareas normales.\n\nUbicacion: \nUsuario: \nSintomas especificos: ',NULL,1,NULL,9,4,2,'1. Revisar uso de CPU/RAM en administrador de tareas\n2. Limpieza de archivos temporales\n3. Escaneo antivirus\n4. Verificar inicio automatico de programas\n5. Si persiste, evaluar mantenimiento preventivo',0,NULL,1,'2026-05-22 02:03:16','2026-05-22 02:03:16'),(7,'Email no funciona','Problema con correo electronico corporativo','mail-x','#7C3AED','Falla en correo electronico','No se puede enviar/recibir correos.\n\nUsuario: \nCliente de correo: \nMensaje de error: ',NULL,2,NULL,9,2,2,'1. Verificar conectividad a internet\n2. Probar acceso por webmail\n3. Revisar configuracion SMTP/IMAP\n4. Verificar espacio en buzon\n5. Validar credenciales',0,NULL,1,'2026-05-22 02:03:16','2026-05-22 02:03:16'),(8,'Mantenimiento preventivo programado','Mantenimiento preventivo de rutina','wrench','#16A34A','Mantenimiento preventivo programado','Mantenimiento preventivo programado para mantener equipos en optimas condiciones.\n\nEquipo(s): \nTareas planeadas: ',NULL,1,NULL,8,4,1,'1. Limpieza interna y externa de equipos\n2. Verificacion de software actualizado\n3. Backup de informacion critica\n4. Pruebas de funcionamiento\n5. Documentar estado de cada componente',0,NULL,1,'2026-05-22 02:03:16','2026-05-22 02:03:16');
/*!40000 ALTER TABLE `plantillas_incidencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedor_contactos`
--

DROP TABLE IF EXISTS `proveedor_contactos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedor_contactos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `proveedor_id` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL COMMENT 'Nombre de la persona contacto',
  `puesto` varchar(100) DEFAULT NULL COMMENT 'ej. Asesor de basculas, Soporte',
  `telefono` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `notas` varchar(255) DEFAULT NULL COMMENT 'ej. Solo turno matutino',
  `es_principal` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Marca el contacto principal',
  `orden` int(11) NOT NULL DEFAULT 0,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_proveedor` (`proveedor_id`),
  CONSTRAINT `fk_contacto_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedor_contactos`
--

LOCK TABLES `proveedor_contactos` WRITE;
/*!40000 ALTER TABLE `proveedor_contactos` DISABLE KEYS */;
INSERT INTO `proveedor_contactos` VALUES (1,1,'Alejandro Lozano','Contacto principal',NULL,'i.lozano@abasteo.mx',NULL,1,1,'2026-05-22 23:59:34'),(2,2,'Aldo Linares','Soporte tecnico','664 385 4983','aldolinares@netsistem.com.mx',NULL,1,1,'2026-05-22 23:59:34'),(3,3,'Deyanira Soto','Asesora de cuenta','662 555 8912','dsoto@metrocarrier.com.mx',NULL,1,1,'2026-05-22 23:59:34'),(4,4,'Ernesto','Asesor de basculas','664 108 6038','ernesto@sipcons.com','Linea de basculas',1,1,'2026-05-22 23:59:34'),(5,4,'Soporte MrTienda','Soporte POS MrTienda','664 120 9235',NULL,'Linea de software MrTienda (puntos de cobro)',0,2,'2026-05-22 23:59:34');
/*!40000 ALTER TABLE `proveedor_contactos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedor_marcas`
--

DROP TABLE IF EXISTS `proveedor_marcas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedor_marcas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `proveedor_id` int(11) NOT NULL,
  `marca` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_proveedor_marca` (`proveedor_id`,`marca`),
  KEY `idx_proveedor` (`proveedor_id`),
  CONSTRAINT `fk_marca_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedor_marcas`
--

LOCK TABLES `proveedor_marcas` WRITE;
/*!40000 ALTER TABLE `proveedor_marcas` DISABLE KEYS */;
/*!40000 ALTER TABLE `proveedor_marcas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedor_tipos_equipo`
--

DROP TABLE IF EXISTS `proveedor_tipos_equipo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedor_tipos_equipo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `proveedor_id` int(11) NOT NULL,
  `tipo` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_proveedor_tipo` (`proveedor_id`,`tipo`),
  KEY `idx_proveedor` (`proveedor_id`),
  CONSTRAINT `fk_tipo_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedor_tipos_equipo`
--

LOCK TABLES `proveedor_tipos_equipo` WRITE;
/*!40000 ALTER TABLE `proveedor_tipos_equipo` DISABLE KEYS */;
INSERT INTO `proveedor_tipos_equipo` VALUES (2,1,'Laptop'),(1,1,'PC'),(3,1,'Perifericos'),(5,2,'Impresora'),(4,2,'PC'),(6,2,'Red'),(8,3,'Red'),(7,3,'Telefonia'),(9,4,'Bascula'),(11,4,'Software de cobro'),(10,4,'Terminal POS');
/*!40000 ALTER TABLE `proveedor_tipos_equipo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL COMMENT 'Nombre comercial',
  `razon_social` varchar(200) DEFAULT NULL,
  `rfc` varchar(20) DEFAULT NULL,
  `servicio` varchar(255) DEFAULT NULL COMMENT 'Descripcion corta del servicio que ofrece',
  `direccion` varchar(255) DEFAULT NULL,
  `telefono` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `sitio_web` varchar(200) DEFAULT NULL,
  `horario_atencion` varchar(255) DEFAULT NULL COMMENT 'ej. Lun-Vie 9-18hr',
  `calificacion` tinyint(3) unsigned DEFAULT NULL COMMENT '1-5 estrellas',
  `notas` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_por_id` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_nombre` (`nombre`),
  KEY `idx_activo` (`activo`),
  KEY `fk_proveedor_creador` (`creado_por_id`),
  CONSTRAINT `fk_proveedor_creador` FOREIGN KEY (`creado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
INSERT INTO `proveedores` VALUES (1,'Abasteo',NULL,NULL,'Proveedor de tecnologia',NULL,NULL,'i.lozano@abasteo.mx',NULL,'Lun-Vie 9:00-18:00',NULL,'Contacto principal: Alejandro Lozano',1,NULL,'2026-05-22 23:59:33','2026-05-22 23:59:33'),(2,'enetSystem',NULL,NULL,'Soporte tecnico',NULL,'664 385 4983','aldolinares@netsistem.com.mx',NULL,'Lun-Vie 9:00-18:00',NULL,'Contacto principal: Aldo Linares',1,NULL,'2026-05-22 23:59:33','2026-05-22 23:59:33'),(3,'Metrocarrier',NULL,NULL,'Lineas troncales',NULL,'662 555 8912','dsoto@metrocarrier.com.mx',NULL,'Lun-Vie 9:00-18:00',NULL,'Contacto principal: Deyanira Soto',1,NULL,'2026-05-22 23:59:33','2026-05-22 23:59:33'),(4,'Sipcons',NULL,NULL,'Punto de cobro y basculas',NULL,NULL,'ernesto@sipcons.com',NULL,'Lun-Vie 9:00-18:00',NULL,'Maneja dos lineas de productos: basculas y MrTienda (POS)',1,NULL,'2026-05-22 23:59:33','2026-05-22 23:59:33');
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordatorios`
--

DROP TABLE IF EXISTS `recordatorios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recordatorios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL COMMENT 'A quién se le envía',
  `titulo` varchar(200) NOT NULL,
  `mensaje` varchar(500) DEFAULT NULL,
  `fecha_envio` datetime NOT NULL COMMENT 'Cuándo enviar',
  `enlace` varchar(255) DEFAULT NULL,
  `entidad` varchar(50) DEFAULT NULL,
  `entidad_id` int(11) DEFAULT NULL,
  `enviado` tinyint(1) NOT NULL DEFAULT 0,
  `enviado_en` timestamp NULL DEFAULT NULL,
  `creado_por_id` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_enviar` (`enviado`,`fecha_envio`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `fk_rec_creador` (`creado_por_id`),
  CONSTRAINT `fk_rec_creador` FOREIGN KEY (`creado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rec_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recordatorios`
--

LOCK TABLES `recordatorios` WRITE;
/*!40000 ALTER TABLE `recordatorios` DISABLE KEYS */;
/*!40000 ALTER TABLE `recordatorios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reglas_asignacion`
--

DROP TABLE IF EXISTS `reglas_asignacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reglas_asignacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL COMMENT 'Nombre descriptivo de la regla',
  `descripcion` varchar(255) DEFAULT NULL,
  `sucursal_id` int(11) DEFAULT NULL,
  `area_id` int(11) DEFAULT NULL,
  `categoria_id` int(11) DEFAULT NULL,
  `tipo_trabajo_id` int(11) DEFAULT NULL,
  `severidad_id` int(11) DEFAULT NULL,
  `asignar_a_id` int(11) NOT NULL,
  `prioridad` int(11) NOT NULL DEFAULT 100 COMMENT 'Menor = se evalúa antes',
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  `veces_aplicada` int(11) NOT NULL DEFAULT 0,
  `creado_por_id` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_activa_prioridad` (`activa`,`prioridad`),
  KEY `idx_sucursal` (`sucursal_id`),
  KEY `idx_area` (`area_id`),
  KEY `fk_regla_categoria` (`categoria_id`),
  KEY `fk_regla_tipo` (`tipo_trabajo_id`),
  KEY `fk_regla_severidad` (`severidad_id`),
  KEY `fk_regla_asignar` (`asignar_a_id`),
  KEY `fk_regla_creador` (`creado_por_id`),
  CONSTRAINT `fk_regla_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_regla_asignar` FOREIGN KEY (`asignar_a_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_regla_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_regla_creador` FOREIGN KEY (`creado_por_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_regla_severidad` FOREIGN KEY (`severidad_id`) REFERENCES `severidades` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_regla_sucursal` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursales` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_regla_tipo` FOREIGN KEY (`tipo_trabajo_id`) REFERENCES `tipos_trabajo` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reglas_asignacion`
--

LOCK TABLES `reglas_asignacion` WRITE;
/*!40000 ALTER TABLE `reglas_asignacion` DISABLE KEYS */;
INSERT INTO `reglas_asignacion` VALUES (1,'Urgencia','Tarea con prioridad inmediata.',1,NULL,NULL,NULL,NULL,10,1,1,0,1,'2026-05-25 01:11:54','2026-05-25 01:11:54');
/*!40000 ALTER TABLE `reglas_asignacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `puede_administrar` tinyint(1) NOT NULL DEFAULT 0,
  `puede_ver_todas_sucursales` tinyint(1) NOT NULL DEFAULT 0,
  `puede_resolver` tinyint(1) NOT NULL DEFAULT 0,
  `puede_crear_solicitud` tinyint(1) NOT NULL DEFAULT 1,
  `puede_ver_reportes` tinyint(1) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Administrador','Control total del sistema, configura todo',1,1,1,1,1,1,'2026-05-20 13:52:18'),(2,'Ingeniero en Sistemas','Atiende y resuelve incidencias en todas las sucursales',0,1,1,1,1,1,'2026-05-20 13:52:18'),(3,'Gerente','Supervisa su sucursal y genera reportes',0,0,0,1,1,1,'2026-05-20 13:52:18'),(4,'Jefe de Área','Crea solicitudes de su área y da seguimiento',0,0,0,1,0,1,'2026-05-20 13:52:18'),(5,'Solo Lectura','Consulta y filtra sin modificar',0,1,0,0,1,1,'2026-05-20 13:52:18');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sesiones`
--

DROP TABLE IF EXISTS `sesiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sesiones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `session_id` varchar(128) NOT NULL COMMENT 'PHP session_id()',
  `ip` varchar(45) DEFAULT NULL COMMENT 'IPv4 o IPv6',
  `user_agent` varchar(500) DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL COMMENT 'Dispositivo detectado (Windows, Mac, Android, iPhone, etc)',
  `navegador` varchar(50) DEFAULT NULL COMMENT 'Navegador detectado',
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  `motivo_cierre` varchar(100) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `ultima_actividad` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `cerrada_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_session_id` (`session_id`),
  KEY `idx_usuario_activa` (`usuario_id`,`activa`),
  KEY `idx_creado` (`creado_en`),
  CONSTRAINT `fk_sesion_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sesiones`
--

LOCK TABLES `sesiones` WRITE;
/*!40000 ALTER TABLE `sesiones` DISABLE KEYS */;
INSERT INTO `sesiones` VALUES (1,1,'mgjtocj2sp3n1i8itbe337fhev','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-23 19:10:02','2026-05-24 15:41:06','2026-05-24 15:41:06'),(2,10,'gh7j9gqtlu614i2uoglpkhp86k','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-24 15:41:18','2026-05-24 15:42:12','2026-05-24 15:42:12'),(3,1,'7aga9rmgppnrab15c6b99olmcq','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-24 15:42:19','2026-05-24 20:10:32','2026-05-24 20:10:32'),(4,10,'5uqdneqee5eqj2g3hhgup3fhld','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-24 20:11:01','2026-05-24 20:17:24','2026-05-24 20:17:24'),(5,1,'iu8sgbqavk8m0qf5764u2ru2n5','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',1,NULL,'2026-05-24 20:17:31','2026-05-25 01:23:01',NULL),(6,2,'jah0epgions33mdcf7jc8nov3q','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'Cerradas por Administrador del Sistema','2026-05-24 20:25:11','2026-05-25 18:08:37','2026-05-25 18:08:37'),(7,1,'r0aovoc4ngcobftumkdvd7nvng','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 01:23:58','2026-05-25 01:34:12','2026-05-25 01:34:12'),(8,1,'gt6i9b003jc951g9gcen8lusdd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 01:34:22','2026-05-25 15:30:52','2026-05-25 15:30:52'),(9,2,'g2jjti6jpvj5c2ct5niqr5qprb','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 15:30:27','2026-05-25 15:32:54','2026-05-25 15:32:54'),(10,2,'sm8l6nvi1mrv94kp4rkp97s8uu','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 15:30:58','2026-05-25 15:32:24','2026-05-25 15:32:24'),(11,10,'de9f0mnv7h6lnmhtquf3krkkdd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 15:32:37','2026-05-25 15:33:09','2026-05-25 15:33:09'),(12,2,'dbspv9g94bbrmu4hntpeaputgn','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 15:32:59','2026-05-25 15:40:44','2026-05-25 15:40:44'),(13,1,'c07cdgd4o0brctf4d3ojc0kuqb','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 15:33:14','2026-05-25 16:27:02','2026-05-25 16:27:02'),(14,2,'ibof84hdqgtk85k0d79en7gnd4','192.168.1.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'Cerradas por Administrador del Sistema','2026-05-25 15:36:35','2026-05-25 18:08:37','2026-05-25 18:08:37'),(15,2,'9q3mrm9llj7ifk2to3nr0asoua','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','Windows 10/11','Edge',0,'logout normal','2026-05-25 15:41:06','2026-05-25 15:50:09','2026-05-25 15:50:09'),(16,2,'0qj4nrav2pkge3stt03bb3r5is','192.168.1.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'Cerradas por Administrador del Sistema','2026-05-25 15:42:10','2026-05-25 18:08:37','2026-05-25 18:08:37'),(17,2,'sglc2sq72hr0dk3mqdkrup71bl','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','Windows 10/11','Edge',0,'Cerradas por Administrador del Sistema','2026-05-25 15:50:12','2026-05-25 18:08:37','2026-05-25 18:08:37'),(18,2,'hfbckojf1qj2vk7dej8cs2gsfo','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 15:51:07','2026-05-25 18:07:06','2026-05-25 18:07:06'),(19,10,'b6a054tge7ted39jv5ff9so2ed','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 16:27:16','2026-05-25 16:28:03','2026-05-25 16:28:03'),(20,1,'6ngkk12j1pr86lj62rsoot99fs','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',0,'logout normal','2026-05-25 16:28:13','2026-05-25 20:05:03','2026-05-25 20:05:03'),(21,1,'600u0brom3g2gsqgbjncr7vhil','192.168.1.152','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',1,NULL,'2026-05-25 18:07:26','2026-05-25 22:54:30',NULL),(22,1,'oc71rju76g5f10bhnjdiotl8p6','100.109.40.60','Mozilla/5.0 (iPhone; CPU iPhone OS 26_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/148.0.7778.166 Mobile/15E148 Safari/604.1','iPhone','Safari',1,NULL,'2026-05-25 18:45:20','2026-05-25 18:45:20',NULL),(23,1,'4av444604t5tkrl1g452ih5hrq','192.168.1.54','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',1,NULL,'2026-05-25 21:02:03','2026-05-25 22:54:27',NULL),(24,1,'7ha5c6jv62ags0in8p3fnlvj0g','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','Windows 10/11','Chrome',1,NULL,'2026-05-25 22:39:28','2026-05-25 22:54:48',NULL),(25,1,'ttogug8k00tdn5oipd8rc7ekde','100.109.40.60','Mozilla/5.0 (iPhone; CPU iPhone OS 26_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/148.0.7778.166 Mobile/15E148 Safari/604.1','iPhone','Safari',1,NULL,'2026-05-25 22:53:13','2026-05-25 22:53:30',NULL);
/*!40000 ALTER TABLE `sesiones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `severidades`
--

DROP TABLE IF EXISTS `severidades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `severidades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `nivel` int(11) NOT NULL,
  `color` varchar(20) NOT NULL DEFAULT '#6B7280',
  `sla_horas` int(11) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`),
  UNIQUE KEY `nivel` (`nivel`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `severidades`
--

LOCK TABLES `severidades` WRITE;
/*!40000 ALTER TABLE `severidades` DISABLE KEYS */;
INSERT INTO `severidades` VALUES (1,'Crítica',1,'#DC2626',2,'Operación detenida, requiere atención inmediata',1),(2,'Alta',2,'#EA580C',8,'Afectación importante a la operación',1),(3,'Media',3,'#D97706',24,'Afectación parcial, no detiene la operación',1),(4,'Baja',4,'#16A34A',72,'Sin afectación operativa, mejora o solicitud',1);
/*!40000 ALTER TABLE `severidades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subcategorias`
--

DROP TABLE IF EXISTS `subcategorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subcategorias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `categoria_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_categoria_nombre` (`categoria_id`,`nombre`),
  CONSTRAINT `subcategorias_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subcategorias`
--

LOCK TABLES `subcategorias` WRITE;
/*!40000 ALTER TABLE `subcategorias` DISABLE KEYS */;
INSERT INTO `subcategorias` VALUES (1,1,'PC',NULL,1,'2026-05-20 13:52:18'),(2,1,'Laptop',NULL,1,'2026-05-20 13:52:18'),(3,1,'Periféricos',NULL,1,'2026-05-20 13:52:18'),(4,1,'Disco duro',NULL,1,'2026-05-20 13:52:18'),(5,2,'Sistema operativo',NULL,1,'2026-05-20 13:52:18'),(6,2,'Office',NULL,1,'2026-05-20 13:52:18'),(7,2,'Sistema de punto de venta',NULL,1,'2026-05-20 13:52:18'),(8,2,'Antivirus',NULL,1,'2026-05-20 13:52:18'),(9,3,'WiFi',NULL,1,'2026-05-20 13:52:18'),(10,3,'Cableado',NULL,1,'2026-05-20 13:52:18'),(11,3,'Internet',NULL,1,'2026-05-20 13:52:18'),(12,3,'VPN',NULL,1,'2026-05-20 13:52:18'),(13,10,'Contraseña',NULL,1,'2026-05-20 13:52:18'),(14,10,'Creación de cuenta',NULL,1,'2026-05-20 13:52:18'),(15,10,'Permisos',NULL,1,'2026-05-20 13:52:18'),(16,9,'Tóner / cartuchos',NULL,1,'2026-05-20 13:52:18'),(17,9,'Atasco de papel',NULL,1,'2026-05-20 13:52:18'),(18,9,'Configuración',NULL,1,'2026-05-20 13:52:18'),(19,7,'Instalación',NULL,1,'2026-05-21 14:08:57');
/*!40000 ALTER TABLE `subcategorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sucursal_plantas`
--

DROP TABLE IF EXISTS `sucursal_plantas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sucursal_plantas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sucursal_id` int(11) NOT NULL,
  `nombre` varchar(80) NOT NULL COMMENT 'Ej: Planta baja, Piso 1, Bodega',
  `orden` int(11) NOT NULL DEFAULT 0 COMMENT 'Para ordenar las pestañas',
  `plano_url` varchar(255) DEFAULT NULL,
  `plano_subido_en` timestamp NULL DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_sucursal` (`sucursal_id`,`orden`),
  CONSTRAINT `fk_planta_sucursal` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursales` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sucursal_plantas`
--

LOCK TABLES `sucursal_plantas` WRITE;
/*!40000 ALTER TABLE `sucursal_plantas` DISABLE KEYS */;
INSERT INTO `sucursal_plantas` VALUES (1,1,'Tienda',1,'uploads/planos/plano_1_1779725269.png','2026-05-25 16:07:49',1,'2026-05-25 16:15:21'),(2,1,'Oficinas',2,'uploads/planos/plano_p2_1779726235.png','2026-05-25 16:23:55',1,'2026-05-25 16:23:39'),(3,1,'3er Piso',3,'uploads/planos/plano_p3_1779726256.png','2026-05-25 16:24:16',1,'2026-05-25 16:24:06');
/*!40000 ALTER TABLE `sucursal_plantas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sucursales`
--

DROP TABLE IF EXISTS `sucursales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sucursales` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `codigo` varchar(20) NOT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `telefono` varchar(50) DEFAULT NULL,
  `responsable` varchar(150) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime DEFAULT current_timestamp(),
  `actualizado_en` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`),
  UNIQUE KEY `codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sucursales`
--

LOCK TABLES `sucursales` WRITE;
/*!40000 ALTER TABLE `sucursales` DISABLE KEYS */;
INSERT INTO `sucursales` VALUES (1,'Bacal','BAC','Av. Cruz del Sur 2025, Fracc. Las Huertas 3ra. Sección, Tijuana','(664) 972 06 31','Alberto Martinez',1,'2026-05-20 13:52:18','2026-05-25 09:35:53'),(2,'Ferias','FER','De las Ferias 84, Lomas Hipodromo, 22030 Tijuana, B.C.','664 104 1093','Omar',1,'2026-05-20 13:52:18','2026-05-25 09:35:41');
/*!40000 ALTER TABLE `sucursales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipos_trabajo`
--

DROP TABLE IF EXISTS `tipos_trabajo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tipos_trabajo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `color` varchar(20) DEFAULT '#6B7280',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipos_trabajo`
--

LOCK TABLES `tipos_trabajo` WRITE;
/*!40000 ALTER TABLE `tipos_trabajo` DISABLE KEYS */;
INSERT INTO `tipos_trabajo` VALUES (1,'PC',NULL,'#DC2626',1,'2026-05-20 13:52:18'),(2,'Alarmas',NULL,'#EA580C',1,'2026-05-20 13:52:18'),(3,'Cámaras',NULL,'#7C3AED',1,'2026-05-20 13:52:18'),(4,'Red',NULL,'#16A34A',1,'2026-05-20 13:52:18'),(5,'Impresora',NULL,'#6B7280',1,'2026-05-20 13:52:18'),(6,'Punto de Venta',NULL,'#D97706',1,'2026-05-20 13:52:18'),(7,'Telefonía',NULL,'#2563EB',1,'2026-05-20 13:52:18'),(8,'Mantenimiento Preventivo',NULL,'#0EA5E9',1,'2026-05-20 13:52:18'),(9,'Mantenimiento Correctivo',NULL,'#DC2626',1,'2026-05-20 13:52:18'),(10,'Instalación',NULL,'#22C55E',1,'2026-05-20 13:52:18'),(11,'Actualización',NULL,'#9333EA',1,'2026-05-20 13:52:18'),(12,'Respaldo',NULL,'#6B7280',1,'2026-05-20 13:52:18'),(13,'Capacitación',NULL,'#0EA5E9',1,'2026-05-20 13:52:18'),(14,'Otro',NULL,'#6B7280',1,'2026-05-20 13:52:18');
/*!40000 ALTER TABLE `tipos_trabajo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `nombre_completo` varchar(150) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `avatar_url` varchar(255) DEFAULT NULL COMMENT 'Ruta relativa de la foto de perfil',
  `pagina_inicio_preferida` varchar(100) DEFAULT 'dashboard.php',
  `telefono` varchar(50) DEFAULT NULL,
  `rol_id` int(11) NOT NULL,
  `sucursal_id` int(11) DEFAULT NULL,
  `area_id` int(11) DEFAULT NULL,
  `puesto` varchar(100) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `ultimo_login` datetime DEFAULT NULL,
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0,
  `bloqueado_hasta` datetime DEFAULT NULL,
  `debe_cambiar_password` tinyint(1) NOT NULL DEFAULT 0,
  `creado_en` datetime DEFAULT current_timestamp(),
  `actualizado_en` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario` (`usuario`),
  KEY `rol_id` (`rol_id`),
  KEY `idx_usuario_activo` (`usuario`,`activo`),
  KEY `idx_sucursal` (`sucursal_id`),
  KEY `idx_area` (`area_id`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `usuarios_ibfk_2` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursales` (`id`) ON DELETE SET NULL,
  CONSTRAINT `usuarios_ibfk_3` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'admin','$2y$10$BVwhlXgJ8.fU8/y00Wh8ueWz2puyUKuadwYyahdi.RgoJKsVIIs7y','Administrador del Sistema','admin@carnesbacal.com',NULL,'dashboard.php',NULL,1,NULL,NULL,'Administrador',NULL,1,'2026-05-25 15:53:13',0,NULL,0,'2026-05-20 13:52:18','2026-05-25 15:53:13'),(2,'abraham','$2y$10$K.eN9iTPNYXbhbMpH//bKepL9QqPxxhtakFJD7xB0AgdzBWMRCEOq','Abraham García',NULL,NULL,'dashboard.php',NULL,2,NULL,NULL,'Ing. Sistemas',NULL,1,'2026-05-25 08:51:07',0,NULL,0,'2026-05-20 17:42:51','2026-05-25 08:51:07'),(3,'carlos','$2y$10$gfGQka6cAAzIvrKDtRmspuKhsrk2585chNfB9tA.qwJE1jFw6HeXW','Carlos Martínez',NULL,NULL,'dashboard.php',NULL,2,NULL,NULL,'Ing. Sistemas',NULL,1,NULL,0,NULL,0,'2026-05-20 17:42:52','2026-05-20 17:42:52'),(4,'diana','$2y$10$gfGQka6cAAzIvrKDtRmspuKhsrk2585chNfB9tA.qwJE1jFw6HeXW','Diana López',NULL,NULL,'dashboard.php',NULL,2,NULL,NULL,'Ing. Sistemas',NULL,1,NULL,0,NULL,0,'2026-05-20 17:42:52','2026-05-20 17:42:52'),(5,'gerente1','$2y$10$gfGQka6cAAzIvrKDtRmspuKhsrk2585chNfB9tA.qwJE1jFw6HeXW','Alberto Martinez','jamartinez@granodeoro.com.mx',NULL,'dashboard.php','6644093639',3,1,3,'Gerente Bacal',NULL,1,'2026-05-21 09:08:24',0,NULL,0,'2026-05-20 17:42:52','2026-05-25 11:11:36'),(6,'gerente2','$2y$10$gfGQka6cAAzIvrKDtRmspuKhsrk2585chNfB9tA.qwJE1jFw6HeXW','Miguel Garcia Sierra','magarcia@granodeoro.com.mx',NULL,'dashboard.php','6643934573',3,1,3,'Gerente Bacal',NULL,1,'2026-05-21 09:10:22',0,NULL,0,'2026-05-20 17:42:52','2026-05-25 11:13:59'),(7,'jefe_cajas','$2y$10$gfGQka6cAAzIvrKDtRmspuKhsrk2585chNfB9tA.qwJE1jFw6HeXW','Beatriz Ramírez',NULL,NULL,'dashboard.php',NULL,4,1,1,'Jefe de Cajas',NULL,1,'2026-05-20 17:47:38',0,NULL,0,'2026-05-20 17:42:52','2026-05-20 17:47:38'),(8,'jefe_carn','$2y$10$gfGQka6cAAzIvrKDtRmspuKhsrk2585chNfB9tA.qwJE1jFw6HeXW','Pedro Morales',NULL,NULL,'dashboard.php',NULL,4,1,11,'Jefe Carnicería',NULL,1,NULL,0,NULL,0,'2026-05-20 17:42:52','2026-05-25 11:06:21'),(9,'jefe_alm','$2y$10$gfGQka6cAAzIvrKDtRmspuKhsrk2585chNfB9tA.qwJE1jFw6HeXW','Nadia Guerrero',NULL,NULL,'dashboard.php',NULL,4,2,5,'Jefe Almacén',NULL,1,NULL,0,NULL,0,'2026-05-20 17:42:52','2026-05-20 17:42:52'),(10,'lfrodriguez','$2y$10$JL7WOEvj/0PzunX9DjRN4eDfSa6UJTk.LTYDAnhG0Rt91p8CsnuBG','Luis Fernando Rodriguez','lfrodriguez@granodeoro.com.mx',NULL,'dashboard.php','6645065978',2,NULL,19,'Encargado de Sistemas',NULL,1,'2026-05-25 09:27:16',0,NULL,0,'2026-05-21 14:04:05','2026-05-25 09:27:16'),(11,'jlcorral','$2y$10$Z6Ta0CqeGyxmFoaw0LB59OvaoTu7YeR2hGbaWqxTfH2FXAy6A.PCK','Jose Luis Corral Terrazas','jlcorral@granodeoro.com.mx',NULL,'dashboard.php',NULL,4,NULL,NULL,NULL,NULL,1,NULL,0,NULL,1,'2026-05-25 11:20:16','2026-05-25 11:20:16');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `v_estadisticas_sucursal`
--

DROP TABLE IF EXISTS `v_estadisticas_sucursal`;
/*!50001 DROP VIEW IF EXISTS `v_estadisticas_sucursal`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_estadisticas_sucursal` AS SELECT
 1 AS `sucursal_id`,
  1 AS `sucursal_nombre`,
  1 AS `total_incidencias`,
  1 AS `abiertas`,
  1 AS `cerradas`,
  1 AS `reincidencias`,
  1 AS `criticas_abiertas`,
  1 AS `tiempo_promedio_resolucion_min` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_incidencias_completas`
--

DROP TABLE IF EXISTS `v_incidencias_completas`;
/*!50001 DROP VIEW IF EXISTS `v_incidencias_completas`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_incidencias_completas` AS SELECT
 1 AS `id`,
  1 AS `folio`,
  1 AS `titulo`,
  1 AS `descripcion`,
  1 AS `fecha_evento`,
  1 AS `fecha_atencion`,
  1 AS `fecha_resolucion`,
  1 AS `fecha_cierre`,
  1 AS `tiempo_respuesta_min`,
  1 AS `tiempo_resolucion_min`,
  1 AS `es_reincidencia`,
  1 AS `veces_recurrida`,
  1 AS `incidencia_padre_id`,
  1 AS `solucion`,
  1 AS `recomendaciones`,
  1 AS `causa_raiz`,
  1 AS `sla_cumplido`,
  1 AS `creado_en`,
  1 AS `sucursal_id`,
  1 AS `sucursal_nombre`,
  1 AS `sucursal_codigo`,
  1 AS `area_id`,
  1 AS `area_nombre`,
  1 AS `area_color`,
  1 AS `categoria_id`,
  1 AS `categoria_nombre`,
  1 AS `categoria_color`,
  1 AS `subcategoria_nombre`,
  1 AS `tipo_trabajo_id`,
  1 AS `tipo_trabajo_nombre`,
  1 AS `tipo_trabajo_color`,
  1 AS `severidad_id`,
  1 AS `severidad_nombre`,
  1 AS `severidad_color`,
  1 AS `severidad_nivel`,
  1 AS `estado_id`,
  1 AS `estado_nombre`,
  1 AS `estado_color`,
  1 AS `estado_es_final`,
  1 AS `equipo_id`,
  1 AS `equipo_codigo`,
  1 AS `equipo_nombre`,
  1 AS `reportado_por_id`,
  1 AS `reportado_por_nombre`,
  1 AS `reportante_nombre`,
  1 AS `asignado_a_id`,
  1 AS `asignado_a_nombre`,
  1 AS `resuelto_por_id`,
  1 AS `resuelto_por_nombre` */;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'carnes_bacal'
--

--
-- Dumping routines for database 'carnes_bacal'
--

--
-- Final view structure for view `v_estadisticas_sucursal`
--

/*!50001 DROP VIEW IF EXISTS `v_estadisticas_sucursal`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_estadisticas_sucursal` AS select `s`.`id` AS `sucursal_id`,`s`.`nombre` AS `sucursal_nombre`,count(`i`.`id`) AS `total_incidencias`,sum(case when `e`.`es_final` = 0 then 1 else 0 end) AS `abiertas`,sum(case when `e`.`es_final` = 1 then 1 else 0 end) AS `cerradas`,sum(case when `i`.`es_reincidencia` = 1 then 1 else 0 end) AS `reincidencias`,sum(case when `sev`.`nivel` = 1 and `e`.`es_final` = 0 then 1 else 0 end) AS `criticas_abiertas`,avg(`i`.`tiempo_resolucion_min`) AS `tiempo_promedio_resolucion_min` from (((`sucursales` `s` left join `incidencias` `i` on(`i`.`sucursal_id` = `s`.`id`)) left join `estados` `e` on(`i`.`estado_id` = `e`.`id`)) left join `severidades` `sev` on(`i`.`severidad_id` = `sev`.`id`)) group by `s`.`id`,`s`.`nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_incidencias_completas`
--

/*!50001 DROP VIEW IF EXISTS `v_incidencias_completas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_incidencias_completas` AS select `i`.`id` AS `id`,`i`.`folio` AS `folio`,`i`.`titulo` AS `titulo`,`i`.`descripcion` AS `descripcion`,`i`.`fecha_evento` AS `fecha_evento`,`i`.`fecha_atencion` AS `fecha_atencion`,`i`.`fecha_resolucion` AS `fecha_resolucion`,`i`.`fecha_cierre` AS `fecha_cierre`,`i`.`tiempo_respuesta_min` AS `tiempo_respuesta_min`,`i`.`tiempo_resolucion_min` AS `tiempo_resolucion_min`,`i`.`es_reincidencia` AS `es_reincidencia`,`i`.`veces_recurrida` AS `veces_recurrida`,`i`.`incidencia_padre_id` AS `incidencia_padre_id`,`i`.`solucion` AS `solucion`,`i`.`recomendaciones` AS `recomendaciones`,`i`.`causa_raiz` AS `causa_raiz`,`i`.`sla_cumplido` AS `sla_cumplido`,`i`.`creado_en` AS `creado_en`,`s`.`id` AS `sucursal_id`,`s`.`nombre` AS `sucursal_nombre`,`s`.`codigo` AS `sucursal_codigo`,`a`.`id` AS `area_id`,`a`.`nombre` AS `area_nombre`,`a`.`color` AS `area_color`,`c`.`id` AS `categoria_id`,`c`.`nombre` AS `categoria_nombre`,`c`.`color` AS `categoria_color`,`sc`.`nombre` AS `subcategoria_nombre`,`tt`.`id` AS `tipo_trabajo_id`,`tt`.`nombre` AS `tipo_trabajo_nombre`,`tt`.`color` AS `tipo_trabajo_color`,`sev`.`id` AS `severidad_id`,`sev`.`nombre` AS `severidad_nombre`,`sev`.`color` AS `severidad_color`,`sev`.`nivel` AS `severidad_nivel`,`e`.`id` AS `estado_id`,`e`.`nombre` AS `estado_nombre`,`e`.`color` AS `estado_color`,`e`.`es_final` AS `estado_es_final`,`eq`.`id` AS `equipo_id`,`eq`.`codigo_inventario` AS `equipo_codigo`,`eq`.`nombre` AS `equipo_nombre`,`rep`.`id` AS `reportado_por_id`,`rep`.`nombre_completo` AS `reportado_por_nombre`,`i`.`reportante_nombre` AS `reportante_nombre`,`asig`.`id` AS `asignado_a_id`,`asig`.`nombre_completo` AS `asignado_a_nombre`,`res`.`id` AS `resuelto_por_id`,`res`.`nombre_completo` AS `resuelto_por_nombre` from (((((((((((`incidencias` `i` left join `sucursales` `s` on(`i`.`sucursal_id` = `s`.`id`)) left join `areas` `a` on(`i`.`area_id` = `a`.`id`)) left join `categorias` `c` on(`i`.`categoria_id` = `c`.`id`)) left join `subcategorias` `sc` on(`i`.`subcategoria_id` = `sc`.`id`)) left join `tipos_trabajo` `tt` on(`i`.`tipo_trabajo_id` = `tt`.`id`)) left join `severidades` `sev` on(`i`.`severidad_id` = `sev`.`id`)) left join `estados` `e` on(`i`.`estado_id` = `e`.`id`)) left join `equipos` `eq` on(`i`.`equipo_id` = `eq`.`id`)) left join `usuarios` `rep` on(`i`.`reportado_por_id` = `rep`.`id`)) left join `usuarios` `asig` on(`i`.`asignado_a_id` = `asig`.`id`)) left join `usuarios` `res` on(`i`.`resuelto_por_id` = `res`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-25 15:54:49
