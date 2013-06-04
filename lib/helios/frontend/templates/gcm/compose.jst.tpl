<header>
  <h1>Send a Google Cloud Message</h1>
</header>

<form id="compose">
  <!-- <fieldset id="recipients">
    <legend>Recipients</legend>

    <ol>
      <li>
        <input type="radio" name="recipients" value="all" id="recipients[all]"/>
        <label for="recipients[all]">All Devices</label>
      </li>
      <li>
        <input type="radio" name="recipients" value="specified" id="recipients[specified]"/>
        <label for="recipients[specified]">Specified Devices</label>
        <textarea id="tokens" name="tokens" rows="3", cols="50"></textarea>
      </li>
    </ol>
  </fieldset> -->

  <fieldset class="message">
    <legend>Payload</legend>

    <div class="span7">
      <textarea id="payload" name="payload" rows="4" cols="50">
  {
    "aps": {
      "alert": "Lorem ipsum dolar sit amet.",
      "badge": 0
    }
  }</textarea>

      <div class="alert">
        <strong></strong> : <span></span>
      </div>
    </div>
  </fieldset>

  <hr/>

  <button id="send" type="button">Send Google Cloud Message</button>
</form>

<figure class="iphone preview">
  <header>
    <figure class="status">
      <span class="signal">▁</span>
      <span class="carrier">Carrier</span>
      <span class="battery">100%</span>
    </figure>

    <time>
      <span class="time">9:04</span>
      <span class="date">Thursday, November 29</span>
    </time>
  </header>

  <figure class="notification">
    <h1>App Name</h1>
    <p></p>
  </figure>

  <footer>
    <figure class="slider">
      <input type="range" value="0"></input>
      <span>slide to view</span>
    </figure>
  </footer>
</figure>
