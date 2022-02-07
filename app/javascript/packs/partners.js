import Inputmask from "./inputmask";

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
  if (!document.querySelector("partner-form")) return;

  function getLocation(setCity = "") {
    const id = document.querySelector("#partner_state_id").value;
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
  let partnerState = document.querySelector("#partner_state_id");
  if (partnerState !== null) {
    partnerState.addEventListener("change", () => {
      getLocation();
    });
  }

  const fillStateAndCity = (stateUf, cityName) => {
    const stateName = ufMap[stateUf];

    const value = [...partnerState.querySelectorAll("option")].find((opt) => {
      return opt.innerHTML === stateName;
    });

    partnerState.value = value.value;
    getLocation(cityName);
  };

  // Mask
  let zipcode = document.getElementById("partner_cep");
  if (zipcode) {
    let im = new Inputmask("99999-999");
    im.mask(zipcode);

    zipcode.addEventListener("input", async (e) => {
      const cep = e.currentTarget.value.replace(/\D+/g, "");
      if (cep.length === 8) {
        const url = `https://viacep.com.br/ws/${cep}/json/`;

        const response = await axios.get(url);
        if (response.status === 200 && !response.data.erro) {
          document.getElementById("partner_street_name").value =
            response.data.logradouro;
          document.getElementById("partner_neighborhood").value =
            response.data.bairro;
          fillStateAndCity(response.data.uf, response.data.localidade);
        }
      } else {
        document.getElementById("partner_street_name").value = "";
        document.getElementById("partner_neighborhood").value = "";
        document.getElementById("partner_state_id").value = "";
        document.getElementById("cities_select").value = "";
      }
    });
  }

  new Inputmask("(99) 99999-9999").mask(
    document.getElementById("partner_contact_phone_1")
  );
  new Inputmask("(99) 99999-9999").mask(
    document.getElementById("partner_contact_phone_2")
  );
  new Inputmask("99.999.999/0001-99").mask(
    document.getElementById("partner_cnpj")
  );
});
