document.addEventListener("turbolinks:load", () => {
  document.querySelectorAll(".file-upload").forEach((fileUpload) => {
    const fileInput = fileUpload.querySelector("input[type=file]");
    const label = fileUpload.querySelector("label");
    const currentImageUrl = fileInput.dataset.currentImageUrl;
    label.appendChild(fileInput);
    const fileUploadHTML = fileInput.outerHTML;
    if (currentImageUrl) {
       label.innerHTML = `<div class="file-div"><img style="height: 300px" src="${currentImageUrl}"/></div>${fileUploadHTML}`;
    }

    label.addEventListener("click", () => {
      label
        .querySelector("input[type=file]")
        .addEventListener("change", (e) => {
          const file = e.target.files[0];
          const fileUploadHTML = fileInput.outerHTML;
          if (file) {
            label.innerHTML = `<div class="file-div"><img style="height: 300px" src="${URL.createObjectURL(
              file
            )}"/></div>${fileUploadHTML}`;
          }
          label.querySelector("input[type=file]").files = e.target.files;
        });
    });
  });
});
