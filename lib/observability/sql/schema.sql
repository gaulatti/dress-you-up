-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema madonna
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `madonna` DEFAULT CHARACTER SET utf8mb3 ;
USE `madonna` ;

-- -----------------------------------------------------
-- Table `madonna`.`teams`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`teams` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `madonna`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sub` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `madonna`.`memberships`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`memberships` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `users_id` INT NOT NULL,
  `teams_id` INT NOT NULL,
  `role` INT NOT NULL,
  PRIMARY KEY (`id`, `users_id`, `teams_id`),
  INDEX `fk_memberships_teams1_idx` (`teams_id` ASC) VISIBLE,
  INDEX `fk_memberships_users1_idx` (`users_id` ASC) VISIBLE,
  CONSTRAINT `fk_memberships_teams1`
    FOREIGN KEY (`teams_id`)
    REFERENCES `madonna`.`teams` (`id`),
  CONSTRAINT `fk_memberships_users1`
    FOREIGN KEY (`users_id`)
    REFERENCES `madonna`.`users` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `madonna`.`projects`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`projects` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `teams_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`, `teams_id`),
  INDEX `fk_projects_teams2_idx` (`teams_id` ASC) VISIBLE,
  CONSTRAINT `fk_projects_teams2`
    FOREIGN KEY (`teams_id`)
    REFERENCES `madonna`.`teams` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `madonna`.`assignments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`assignments` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `projects_id` INT NOT NULL,
  `memberships_id` INT NOT NULL,
  `role` INT NOT NULL,
  PRIMARY KEY (`id`, `projects_id`, `memberships_id`),
  INDEX `fk_assignments_projects1_idx` (`projects_id` ASC) VISIBLE,
  INDEX `fk_assignments_memberships1_idx` (`memberships_id` ASC) VISIBLE,
  CONSTRAINT `fk_assignments_memberships1`
    FOREIGN KEY (`memberships_id`)
    REFERENCES `madonna`.`memberships` (`id`),
  CONSTRAINT `fk_assignments_projects1`
    FOREIGN KEY (`projects_id`)
    REFERENCES `madonna`.`projects` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `madonna`.`targets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`targets` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `projects_id` INT NOT NULL,
  `stage` INT NOT NULL,
  `provider` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `url` TEXT NULL DEFAULT NULL,
  `lambda_arn` VARCHAR(110) NULL DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`, `projects_id`),
  INDEX `fk_targets_projects2_idx` (`projects_id` ASC) VISIBLE,
  CONSTRAINT `fk_targets_projects2`
    FOREIGN KEY (`projects_id`)
    REFERENCES `madonna`.`projects` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `madonna`.`beacons`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`beacons` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `teams_id` INT NOT NULL,
  `targets_id` INT NULL DEFAULT NULL,
  `triggered_by` INT NULL DEFAULT NULL,
  `stage` INT NOT NULL,
  `uuid` VARCHAR(45) NOT NULL,
  `url` TEXT NOT NULL,
  `provider` INT NOT NULL,
  `type` INT NOT NULL,
  `fcp` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `lcp` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `tti` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `si` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `cls` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `mode` INT NOT NULL,
  `performance_score` INT NOT NULL DEFAULT '0',
  `pleasantness_score` INT NULL DEFAULT NULL,
  `status` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ended_at` DATETIME NOT NULL,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`, `teams_id`),
  INDEX `fk_performance_executions_targets1_idx` (`targets_id` ASC) VISIBLE,
  INDEX `fk_performance_executions_teams1_idx` (`teams_id` ASC) VISIBLE,
  INDEX `fk_performance_executions_assignments1_idx` (`triggered_by` ASC) VISIBLE,
  CONSTRAINT `fk_performance_executions_assignments1`
    FOREIGN KEY (`triggered_by`)
    REFERENCES `madonna`.`assignments` (`id`),
  CONSTRAINT `fk_performance_executions_targets1`
    FOREIGN KEY (`targets_id`)
    REFERENCES `madonna`.`targets` (`id`),
  CONSTRAINT `fk_performance_executions_teams1`
    FOREIGN KEY (`teams_id`)
    REFERENCES `madonna`.`teams` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `madonna`.`engagement`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`engagement` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `targets_id` INT NOT NULL,
  `bounce_rate` INT NOT NULL,
  `mode` INT NOT NULL,
  `date_from` DATETIME NOT NULL,
  `date_to` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`, `targets_id`),
  INDEX `fk_bounce_statistics_targets1_idx` (`targets_id` ASC) VISIBLE,
  CONSTRAINT `fk_bounce_statistics_targets1`
    FOREIGN KEY (`targets_id`)
    REFERENCES `madonna`.`targets` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `madonna`.`schedules`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`schedules` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `targets_id` INT NOT NULL,
  `provider` INT NOT NULL,
  `cron` VARCHAR(45) NOT NULL,
  `next_execution` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`, `targets_id`),
  INDEX `fk_schedules_targets2_idx` (`targets_id` ASC) VISIBLE,
  CONSTRAINT `fk_schedules_targets2`
    FOREIGN KEY (`targets_id`)
    REFERENCES `madonna`.`targets` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `madonna`.`statistics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `madonna`.`statistics` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `targets_id` INT NOT NULL,
  `provider` INT NOT NULL,
  `period` INT NOT NULL,
  `statistic` INT NOT NULL,
  `fcp` DECIMAL(10,2) NOT NULL,
  `lcp` DECIMAL(10,2) NOT NULL,
  `tti` DECIMAL(10,2) NOT NULL,
  `si` DECIMAL(10,2) NOT NULL,
  `cls` DECIMAL(10,2) NOT NULL,
  `mode` INT NOT NULL,
  `count` INT NOT NULL,
  `performance_score` INT NOT NULL,
  `pleasantness_score` INT NULL DEFAULT NULL,
  `date_from` DATETIME NOT NULL,
  `date_to` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`, `targets_id`),
  INDEX `fk_performance_statistics_targets1_idx` (`targets_id` ASC) VISIBLE,
  CONSTRAINT `fk_performance_statistics_targets1`
    FOREIGN KEY (`targets_id`)
    REFERENCES `madonna`.`targets` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;