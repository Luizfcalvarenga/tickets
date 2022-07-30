document.addEventListener("turbolinks:load", () => {
  document.querySelectorAll(".file-upload").forEach((fileUpload) => {
    const fileInput = fileUpload.querySelector("input[type=file]");
    const label = fileUpload.querySelector("label");
    label.appendChild(fileInput);

    const prepareFileUpload = () => {
      const fileInput = label.querySelector("input[type=file]");
      console.log(fileInput)
      label.addEventListener("click", () => {
        label
          .querySelector("input[type=file]")
          .addEventListener("change", (e) => {
            const file = e.target.files[0];
            const fileUploadHTML = fileInput.outerHTML;
            if (file) {
              label.innerHTML = `<div class="file-div"><img style="height: 200px" src="${URL.createObjectURL(
                file
              )}"/></div>${fileUploadHTML}`;
            }
            label.querySelector("input[type=file]").files = e.target.files;
          });
      });

    };
    prepareFileUpload();
  });
});
