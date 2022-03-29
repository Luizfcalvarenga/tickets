import Inputmask from "./inputmask"

const ufMap = {
  RO: "Rondônia",
  AC: "Acre",
  AM: "Amazonas",
  RR: "Roraima",
  PA: "Pará",
  AP: "Amapá",
  TO: "Tocantins",
  MA: "Maranhão",
  PI: "Piauí",
  CE: "Ceará",
  RN: "Rio Grande do Norte",
  PB: "Paraíba",
  PE: "Pernambuco",
  AL: "Alagoas",
  SE: "Sergipe",
  BA: "Bahia",
  MG: "Minas Gerais",
  ES: "Espírito Santo",
  RJ: "Rio de Janeiro",
  SP: "São Paulo",
  PR: "Paraná",
  SC: "Santa Catarina",
  RS: "Rio Grande do Sul",
  MS: "Mato Grosso do Sul",
  MT: "Mato Grosso",
  GO: "Goiás",
  DF: "Distrito Federal",
};

document.addEventListener("turbolinks:load", () => {
  function getLocation(setCity = "") {
    const id = document.querySelector(".select-state").value;
    fetch(`/cities_by_state?state_id=${id}`)
      .then((response) => response.json())
      .then((data) => {
        let citiesSelect = document.querySelector(".select-city");
        citiesSelect.innerHTML = "";
        data.forEach((city) => {
          let option = document.createElement("option");
          option.text = city.name;
          option.value = city.id;
          citiesSelect.add(option);

          if (setCity && setCity === city.name) {
            document.querySelector(".select-city").value = city.id;
          }
        });
      });
  }
  let selectState = document.querySelector(".select-state");
  if (selectState !== null) {
    selectState.addEventListener("change", () => {
      getLocation();
    });
  }
  
  const fillStateAndCity = (stateUf, cityName) => {
    const stateName = ufMap[stateUf];

    const value = [...selectState.querySelectorAll("option")].find((opt) => {
      return opt.innerHTML === stateName
    })

    selectState.value = value.value
    getLocation(cityName)
  }

  // Mask
  let zipcode = document.querySelector(".input-cep");
  if (zipcode) {
    let im = new Inputmask("99999-999");
    im.mask(zipcode);

    zipcode.addEventListener("input", async (e) => {
      const cep = e.currentTarget.value.replace(/\D+/g, "");
      if (cep.length === 8) {
        const url = `https://viacep.com.br/ws/${cep}/json/`;

        const response = await axios.get(url);
        if (response.status === 200 && !response.data.erro) {
          document.querySelector(".input-street-name").value =
            response.data.logradouro;
          document.querySelector(".input-neighborhood").value =
            response.data.bairro;
          fillStateAndCity(response.data.uf, response.data.localidade);
        }
      } else {
        document.querySelector(".input-street-name").value = "";
        document.querySelector(".input-neighborhood").value = "";
        document.querySelector(".input-state-id").value = "";
        document.querySelector(".select-city").value = "";
      }
    });
  }
});
