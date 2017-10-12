Graph1 = {

    populate: function() {
        var ctx = document.getElementById("myChart").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ["Austin", "Boston", "Chicago", "Los Angeles", "New York", "Portland", "San Francisco", "Washington D.C.", "Fairfax County VA"],
                datasets: [{
                    label: 'Junior',
                    backgroundColor: "rgba(153, 102, 255, 0.7)",
                    borderColor: "rgba(102, 26, 255,1)",
                    data: [1, 3, 0, 2, 2, 0, 0, 0, 3, 2]
                }, {
                    label: 'Mid',
                    backgroundColor: "rgba(0, 204, 255, 0.7)",
                    borderColor: "rgba(0, 143, 179,1)",
                    data: [36, 43, 34, 40, 76, 14, 84, 83, 64, 86]
                }, {
                    label: 'Senior',
                    backgroundColor: "rgba(255, 153, 51, 0.7)",
                    borderColor: "rgba(255, 128, 0, 1)",
                    data: [32, 30, 43, 16, 56, 7, 59, 50, 29, 13]
                }]
            },
            options: {
              title: {
           display: true,
           text: 'Number of Job Listings on Indeed.com by City and Experience'
       }
            }
        });
    }
}

document.addEventListener('DOMContentLoaded', Graph1.populate, false);
