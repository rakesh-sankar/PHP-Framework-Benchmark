<?php
require_once 'Zend/Controller/Action.php';
class IndexController extends Zend_Controller_Action
{
    public function indexAction()
    {
		Zend_Controller_Action_HelperBroker::removeHelper('ViewRenderer');
    	echo( 'hello world');
    }
}
