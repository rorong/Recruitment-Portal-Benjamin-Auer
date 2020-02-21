$(document).on('ready turbolinks:load', function() {
    $("#package").change(function(){
    	console.log($("#package").val());
        if(($("#package").val() == 2) || ($("#package").val() == 3)){
          $(".hidden-option").fadeIn('fast'); 
          $(".buy-btn").fadeIn('fast');

        }  
        if($("#package").val() == 1){
          $(".hidden-option").fadeOut('fast');
          $(".buy-btn").fadeIn('fast');            
        }         
        if($("#package").val() == 0){
        	$(".hidden-option").fadeOut('fast');
        	$(".buy-btn").fadeOut('fast');  
        }  
    });        
});
