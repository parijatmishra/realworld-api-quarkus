package org.example.realworldapi.domain.service.impl;

import org.example.realworldapi.domain.entity.User;
import org.example.realworldapi.domain.exception.*;
import org.example.realworldapi.domain.repository.UsersRepository;
import org.example.realworldapi.domain.security.Role;
import org.example.realworldapi.domain.service.JWTService;
import org.example.realworldapi.domain.service.UsersService;
import org.example.realworldapi.web.exception.ResourceNotFoundException;
import org.mindrot.jbcrypt.BCrypt;

import javax.enterprise.context.ApplicationScoped;
import javax.transaction.Transactional;
import java.util.Optional;

@ApplicationScoped
public class UsersServiceImpl implements UsersService {

    private UsersRepository usersRepository;
    private JWTService jwtService;

    public UsersServiceImpl(UsersRepository usersRepository,
                            JWTService jwtService) {
        this.usersRepository = usersRepository;
        this.jwtService = jwtService;
    }

    @Override
    @Transactional
    public User create(String username, String email, String password) {

        checkExistingUsername(username);
        checkExistingEmail(email);

        User user = new User();
        user.setUsername(username);
        user.setEmail(email.toUpperCase().trim());
        user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));

       Optional<User> resultUser = usersRepository.create(user);

       resultUser.ifPresent(createdUser ->
               createdUser.setToken(createJWT(createdUser)));

        return resultUser.orElseThrow(UserNotCreatedException::new);
    }



    private String createJWT(User user) {
        return jwtService.sign(user.getId().toString(), Role.USER);
    }

    private void checkExistingUsername(String username) {
        if(usersRepository.existsBy("username", username)){
            throw new UsernameAlreadyExistsException();
        }
    }

    private void checkExistingEmail(String email) {
        if(usersRepository.existsBy("email", email)){
            throw new EmailAlreadyExistsException();
        }
    }

    @Override
    @Transactional
    public User login(String email, String password) {

        Optional<User> userOptional = usersRepository.findByEmail(email);

        if(!userOptional.isPresent()){
            throw new UserNotFoundException();
        }

        if(isPasswordInvalid(password, userOptional.get())){
           throw new InvalidPasswordException();
        }

        userOptional.ifPresent(loggedUser-> loggedUser.setToken(createJWT(loggedUser)));

        return usersRepository.update(userOptional.get());
    }

    @Override
    @Transactional
    public User findById(Long id) {
        return usersRepository.findById(id).orElseThrow(ResourceNotFoundException::new);
    }

    @Override
    @Transactional
    public User update(User user) {

        checkValidations(user);

        Optional<User> managedUserOptional = usersRepository.findById(user.getId());

        managedUserOptional.ifPresent(storedUser -> {

            if(isPresent(user.getUsername())){
                storedUser.setUsername(user.getUsername());
            }

            if(isPresent(user.getEmail())){
                storedUser.setEmail(user.getEmail());
            }

            if(isPresent(user.getBio())){
                storedUser.setBio(user.getBio());
            }

            if(isPresent(user.getImage())){
                storedUser.setImage(user.getImage());
            }

        });

        return managedUserOptional.orElse(null);
    }


    private boolean isPresent(String property){
        return property != null && !property.isEmpty();
    }

    private boolean isPasswordInvalid(String password, User user) {
        return !BCrypt.checkpw(password, user.getPassword());
    }

    private void checkValidations(User user){

        if(isPresent(user.getUsername())){
            checkUsername(user.getId(), user.getUsername());
        }

        if(isPresent(user.getEmail())){
            checkEmail(user.getId(), user.getEmail());
        }

    }

    private void checkUsername(Long selfId, String username) {
        if(usersRepository.existsUsername(selfId, username)){
            throw new UsernameAlreadyExistsException();
        }
    }

    private void checkEmail(Long selfId, String email) {
        if(usersRepository.existsEmail(selfId, email)){
            throw new EmailAlreadyExistsException();
        }
    }

}
