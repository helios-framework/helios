<h1>New Issue</h1>

<form id="new">
  <ol>
    <li>
      <label>Title</lable>
      <input type="text" name="title"/>
    </li>
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
      <label>Published At</lable>
      <input type="datetime" name="published_at"/>
    </li>
  </ol>

  <button id="create" type="button">Create</button>
</form>
