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
    const id = document.querySelector("#event_state_id").value;
    fetch(`/cities_by_state?state_id=${id}`)
      .then((response) => response.json())
      .then((data) => {
        let citiesSelect = document.getElementById("cities_select");
        citiesSelect.innerHTML = "";
        data.forEach((city) => {
          let option = document.createElement("option");
          option.text = city.name;
          option.value = city.id;
          citiesSelect.add(option);

          if (setCity && setCity === city.name) {
            document.querySelector("#cities_select").value = city.id;
          }
        });
      });
  }
  let eventState = document.querySelector("#event_state_id");
  if (eventState !== null) {
    eventState.addEventListener("change", () => {
      getLocation();
    });
  }
  
  const fillStateAndCity = (stateUf, cityName) => {
    const stateName = ufMap[stateUf];

    const value = [...eventState.querySelectorAll("option")].find((opt) => {
      return opt.innerHTML === stateName
    })

    eventState.value = value.value
    getLocation(cityName)
  }

  // Mask
  let zipcode = document.getElementById("event_cep");
  if (zipcode) {
    let im = new Inputmask("99999-999");
    im.mask(zipcode);

    zipcode.addEventListener("input", async (e) => {
      const cep = e.currentTarget.value.replace(/\D+/g, "");
      if (cep.length === 8) {
        const url = `https://viacep.com.br/ws/${cep}/json/`;

        const response = await axios.get(url);
        if (response.status === 200 && !response.data.erro) {
          document.getElementById("event_street_name").value =
            response.data.logradouro;
          document.getElementById("event_neighborhood").value =
            response.data.bairro;
          fillStateAndCity(response.data.uf, response.data.localidade);
        }
      } else {
        document.getElementById("event_street_name").value = "";
        document.getElementById("event_neighborhood").value = "";
        document.getElementById("event_state_id").value = "";
        document.getElementById("cities_select").value = "";
      }
    });
  }
});
