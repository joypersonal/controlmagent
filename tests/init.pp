class {'controlmagent':
    userLogin => "ctmuser",
    installDir => "/HOLA",
    primaryServer => "ctm8rhserver",
    authorizedServers => "ctm8rhserver",
  }
