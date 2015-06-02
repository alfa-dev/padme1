$(document).ready(function(){

  var delay;
  var $form   = $("form");
  var $submit = $("form input[type='submit']");

  $submit.hide();

  $("textarea").on("keypress change",function(){
      
    clearTimeout(delay);

    delay = setTimeout(function(){
      $form.submit();
    },2000);  
  });

  $form.submit(function(){
    fields = $form.serialize();

    $.ajax({
      url: $form.attr('action'),
      data: fields,
      method: 'post',
      success: function(data){
        console.log('save',data);
      }
    });

    return false;
  });
});
