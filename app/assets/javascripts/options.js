$(document).on('ready turbolinks:load', function() {
    $("#package").change(function(){
    	
        if(($("#package").val() == "Receive email once a week") || ($("#package").val() == "Receive email once every two weeks")){
          $(".hidden-option").fadeIn('fast'); 

        }  
        if($("#package").val() == "Receive emails daily"){
          $(".hidden-option").fadeOut('fast'); 
            
        }           
    });        
});