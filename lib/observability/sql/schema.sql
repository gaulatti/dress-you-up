-- MySQL Script generated by MySQL Workbench
-- Thu Aug 22 13:27:54 2024
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Table `teams`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `teams` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
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
-- Table `memberships`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `memberships` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `users_id` INT NOT NULL,
  `teams_id` INT NOT NULL,
  `role` INT NOT NULL,
  PRIMARY KEY (`id`, `users_id`, `teams_id`),
  INDEX `fk_memberships_teams1_idx` (`teams_id` ASC) VISIBLE,
  INDEX `fk_memberships_users1_idx` (`users_id` ASC) VISIBLE,
  CONSTRAINT `fk_memberships_teams1`
    FOREIGN KEY (`teams_id`)
    REFERENCES `teams` (`id`),
  CONSTRAINT `fk_memberships_users1`
    FOREIGN KEY (`users_id`)
    REFERENCES `users` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `projects`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `projects` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `teams_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`, `teams_id`),
  INDEX `fk_projects_teams2_idx` (`teams_id` ASC) VISIBLE,
  CONSTRAINT `fk_projects_teams2`
    FOREIGN KEY (`teams_id`)
    REFERENCES `teams` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `assignments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `assignments` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `projects_id` INT NOT NULL,
  `memberships_id` INT NOT NULL,
  `role` INT NOT NULL,
  PRIMARY KEY (`id`, `projects_id`, `memberships_id`),
  INDEX `fk_assignments_projects1_idx` (`projects_id` ASC) VISIBLE,
  INDEX `fk_assignments_memberships1_idx` (`memberships_id` ASC) VISIBLE,
  CONSTRAINT `fk_assignments_memberships1`
    FOREIGN KEY (`memberships_id`)
    REFERENCES `memberships` (`id`),
  CONSTRAINT `fk_assignments_projects1`
    FOREIGN KEY (`projects_id`)
    REFERENCES `projects` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `targets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `targets` (
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
    REFERENCES `projects` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `engagement`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `engagement` (
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
    REFERENCES `targets` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `pulses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pulses` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `teams_id` INT NOT NULL,
  `targets_id` INT NULL DEFAULT NULL,
  `triggered_by` INT NULL DEFAULT NULL,
  `stage` INT NOT NULL,
  `url` TEXT NOT NULL,
  `provider` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  `uuid` BINARY(16) NOT NULL,
  PRIMARY KEY (`id`, `teams_id`),
  UNIQUE INDEX `uuid_unique_idx` (`uuid` ASC) VISIBLE,
  INDEX `fk_performance_executions_targets1_idx` (`targets_id` ASC) VISIBLE,
  INDEX `fk_performance_executions_teams1_idx` (`teams_id` ASC) VISIBLE,
  INDEX `fk_performance_executions_assignments1_idx` (`triggered_by` ASC) VISIBLE,
  CONSTRAINT `fk_performance_executions_memberships1`
    FOREIGN KEY (`triggered_by`)
    REFERENCES `memberships` (`id`),
  CONSTRAINT `fk_performance_executions_targets1`
    FOREIGN KEY (`targets_id`)
    REFERENCES `targets` (`id`),
  CONSTRAINT `fk_performance_executions_teams1`
    FOREIGN KEY (`teams_id`)
    REFERENCES `teams` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `heartbeats`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `heartbeats` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `pulses_id` INT NOT NULL,
  `retries` INT NOT NULL DEFAULT '0',
  `ttfb` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `fcp` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `dcl` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `lcp` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `tti` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `si` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `cls` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `screenshots` JSON NULL DEFAULT NULL,
  `mode` INT NOT NULL,
  `performance_score` INT NOT NULL DEFAULT '0',
  `accessibility_score` INT NOT NULL DEFAULT '0',
  `seo_score` INT NOT NULL DEFAULT '0',
  `best_practices_score` INT NOT NULL DEFAULT '0',
  `status` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ended_at` DATETIME NULL DEFAULT NULL,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_heartbeats_pulses1_idx` (`pulses_id` ASC) VISIBLE,
  CONSTRAINT `fk_heartbeats_pulses1`
    FOREIGN KEY (`pulses_id`)
    REFERENCES `pulses` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `schedules`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `schedules` (
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
    REFERENCES `targets` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `statistics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `statistics` (
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
    REFERENCES `targets` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
