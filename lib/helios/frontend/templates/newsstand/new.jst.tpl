<h1>New Issue</h1>

<form id="new" action="<%= Helios.services['newsstand']%>/issues" method="post" enctype="multipart/form-data">
  <ol>
    <li>
      <label>Name</lable>
      <input type="text" name="name"/>
    </li>
    <li>
      <label>Summary</lable>
      <textarea name="summary"/>
    </li>
    <li>
      <label>Covers</lable>
      <input type="file" name="covers[]" multiple/>
    </li>
    <li>
      <label>Assets</lable>
      <input type="file" name="assets[]" multiple/>
    </li>
    <li>
      <label>Published</lable>
      <input type="datetime-local" name="published_at"/>
    </li>
  </ol>

  <button id="create" type="button">Create</button>
</form>
