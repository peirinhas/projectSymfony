<?php

namespace AppBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class PruebasController extends Controller
{

    public function indexAction(Request $request, $lang, $name,$page)
    {

        // Renderizamos a la vista que esta en la carpeta default del app
        /*return $this->render('default/index.html.twig', [
            'base_dir' => realpath($this->getParameter('kernel.project_dir')).DIRECTORY_SEPARATOR,
        ]);*/

        // Renderizamos a la vista que esta en el bundle donde se encuentra nuestro controlador, ya que indicamos el bundle
        // donde se encuentra el controlador y a la carpeta resource donde se encuentra
        return $this->render('AppBundle:Pruebas:index.html.twig', [
            'texto' => 'Envio des de el controlador prueba'.$lang.'-'.$name.'-'.$page
        ]);
    }
}
