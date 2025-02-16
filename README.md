<a href="https://gitmoji.dev">
  <img
    src="https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg?style=flat-square"
    alt="Gitmoji"
  />
</a>

<h1>Streaming data Generator for GCP Pub/Sub</h1>
This project pushed messages from bitcoin transactions to a pub/sub topic from a local machine.
<h2>Configuration</h2>
<ol>
  <li>Create a virtual environment <a href=https://python.land/virtual-environments/virtualenv>https://python.land/virtual-environments/virtualenv</a></li>
  <li>Activate the virtual environment <a href=https://python.land/virtual-environments/virtualenv>https://python.land/virtual-environments/virtualenv</a></li>
  <li>Install GCP CLI </li>
  <li>Install the project dependencies <code> pip install -r requirements.txt </code></li>
  <li>Initialize your cloud <code>gcloud init</code></li>
  <li>Authenticate <code>gcloud auth login</code></li>
  <li>Create a Service Account and grant pubsub.admin permissions </li>
</ol>
