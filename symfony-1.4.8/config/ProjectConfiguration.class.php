<?php

# FROZEN_SF_LIB_DIR: /tmp/symfony-for-release/1.1.1/lib

require_once dirname(__FILE__).'/../lib/autoload/sfCoreAutoload.class.php';
sfCoreAutoload::register();

class ProjectConfiguration extends sfProjectConfiguration
{
  public function setup()
  {
  }
}
