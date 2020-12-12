#####################################################################
# MODULES
#####################################################################

module "module_one" {
  source = ".\\module_one"
}

 module "module_two" {
   source = ".\\module_two"
   depends_on = [module.module_one.module_one,]
}

