$(document).ready(function(){

  var delay;
  var $form       = $("form");
  var $submit     = $("form input[type='submit']");
  var $mark_down  = $("#mark_down");
  var $pad_text   = $(".pad_text");
  var $save       = $("#save");

  $save.hide();
  $submit.hide();
  $pad_text.focus();

  $mark_down.on("click", function(){
    var pad_text = $pad_text.html();
    $mark_down.hide();
    $pad_text.focus().html("").html(pad_text);
  });

  $("textarea").on("keypress change",function(){
    
    $mark_down.hide();
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
        // TODO
        $save.fadeIn("fast").fadeOut(5000);
      }
    });

    return false;
  });

  $( window ).unload(function() {
    $form.submit();
  });
});
