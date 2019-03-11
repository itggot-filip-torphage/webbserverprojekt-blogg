window.localStorage.backgroundColor = "lightgray";

function setColor(color) {
    const element = document.getElementsByTagName("header");
    element[0].style.backgroundColor = color;
    window.localStorage.backgroundColor = color;
}

document.addEventListener("DOMContentLoaded", function(event) {
    document.getElementsByTagName("header")[0].style.backgroundColor=window.localStorage.backgroundColor;
});

const element = document.getElementsByTagName("header");
element[0].style.backgroundColor = g.color;
