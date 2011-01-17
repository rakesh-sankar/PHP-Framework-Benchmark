<?php

require_once dirname(__FILE__).'/toro.php';

class MainHandler extends ToroHandler {
    public function get() { 
        echo 'Hello, world';
    }
}

$site = new ToroApplication(array(
    array('/', 'MainHandler')
));

$site->serve();
