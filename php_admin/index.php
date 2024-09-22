<?php
$htpasswd_file = "/usr/local/apache2/conf/.htpasswd";

// Function to add user
if (isset($_POST['add_user'])) {
    $username = escapeshellarg($_POST['username']);
    $password = escapeshellarg($_POST['password']);
    exec("htpasswd -b $htpasswd_file $username $password");
}

// Function to delete user
if (isset($_POST['delete_user'])) {
    $username = escapeshellarg($_POST['username']);
    exec("htpasswd -D $htpasswd_file $username");
}

// List current users
$users = file($htpasswd_file);
?>

<h2>User Management Interface</h2>

<form method="POST">
    <h3>Add User</h3>
    <input type="text" name="username" placeholder="Username" required>
    <input type="password" name="password" placeholder="Password" required>
    <button type="submit" name="add_user">Add User</button>
</form>

<form method="POST">
    <h3>Delete User</h3>
    <input type="text" name="username" placeholder="Username" required>
    <button type="submit" name="delete_user">Delete User</button>
</form>

<h3>Current Users:</h3>
<ul>
    <?php foreach ($users as $user) {
        $user_parts = explode(':', $user);
        echo "<li>" . $user_parts[0] . "</li>";
    } ?>
</ul>
