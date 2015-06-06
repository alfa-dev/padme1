$(document).ready(function(){

  var delay;
  var $form       = $("form.new_pad, form.edit_pad");
  var $submit     = $(".edit_pad input[type='submit'], .new_pad input[type='submit']");
  var $mark_down  = $("#mark_down");
  var $pad_text   = $(".pad_text");
  var $status     = $("#status");

  $status.hide();
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

    window.onbeforeunload = function() {
      return "O Texto ainda não foi completamente salvo!";
    } 

    delay = setTimeout(function(){
      $form.submit();
      $status
        .html("carregando")
        .addClass("loading")
        .removeClass("save")
        .show();
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
        $status
        .html("salvo")
        .addClass("save")
        .removeClass("loading")
        .show();
        
        setTimeout(function(){
          $status.fadeOut();
        },2000);

        window.onbeforeunload = undefined;
      }
    });

    return false;
  });

  $( window ).unload(function() {
    $form.submit();
  });
});
