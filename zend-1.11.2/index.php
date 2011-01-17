<?php

set_include_path(dirname(__FILE__).'/library');

require_once 'Zend/Controller/Front.php';
Zend_Controller_Front::run(dirname(__FILE__)."/application/controllers");

