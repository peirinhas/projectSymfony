<?php

namespace BlogBundle\Controller;

use BlogBundle\Form\UserType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use BlogBundle\Entity\User;
use Symfony\Component\HttpFoundation\Session\Session;


class UserController extends Controller
{
    private $session;

    public function __construct()
    {
        $this->session=new Session();
    }

    public function loginAction(Request $request)
    {
        $autheticantionUtils = $this->get("security.authentication_utils");
        $error = $autheticantionUtils->getLastAuthenticationError();
        $lastUsername = $autheticantionUtils->getLastUsername();

        $user= new User();
        $form =$this->createForm(UserType::class,$user);

        $form->handleRequest($request);

        if($form->isSubmitted()) {
            if ($form->isValid()) {
                $em=$this->getDoctrine()->getEntityManager();
                $user_repo=$em->getRepository("BlogBundle:User");
                $user=$user_repo->findOneBy(array("email"=>$form->get("email")->getData()));

                if (count($user)==0) {
                    $user = new User();
                    $user->setName($form->get("name")->getData());
                    $user->setSurname($form->get("surname")->getData());
                    $user->setEmail($form->get("email")->getData());

                    //es otra forma de tener un objeto tin tener que crearlo con el new obj()
                    $factory = $this->get("security.encoder_factory");

                    //vamos a codificar la contraseña con el bcrypt definido en el security.yml
                    //tenemos que pasar la entidad user, ya que en el security hemos definido que sería la entidad user la que se codifique
                    $encoder = $factory->getEncoder($user);
                    $password = $encoder->encodePassword($form->get("password")->getData(), $user->getSalt());

                    $user->setPassword($password);
                    $user->setRole("ROLE_ADMIN");
                    $user->setImagen(null);

                    $em = $this->getDoctrine()->getEntityManager();
                    $em->persist($user);
                    $flush = $em->flush();

                    if ($flush == null) {
                        $status = "Te has registrado correctamente";
                    } else {
                        $status = "No te has registrado correctamente";
                    }
                }else{
                    $status="Usuario ya existe";
                }
            } else {
                $status = "No te has registrado correctamente";
            }

            $this->session->getFlashBag()->add("status", $status);
        }
        return $this->render("BlogBundle:User:login.html.twig", [
            "error" => $error,
            "lastUsername" => $lastUsername,
            "form"=>$form->createView()
        ]);
    }
}
