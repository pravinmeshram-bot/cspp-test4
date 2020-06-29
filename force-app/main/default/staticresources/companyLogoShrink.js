window.onscroll = function() {scrollFunction()};

function scrollFunction() {
  if (document.body.scrollTop > 39|| document.documentElement.scrollTop > 39) {
     document.getElementById("smalllogo").style.height = "40px";
	 document.getElementById("smalllogo").style.top = "0";
	 document.getElementById("thelogo").style.display = "none";
	 document.getElementById("smalllogo").style.display = "block";
  } else {
     document.getElementById("thelogo").style.height = "5.3rem";
	 document.getElementById("thelogo").style.top = "-3rem";
	 document.getElementById("thelogo").style.display = "block";
	 document.getElementById("smalllogo").style.display = "none";
  }
}

